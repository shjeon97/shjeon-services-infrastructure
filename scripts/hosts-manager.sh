#!/bin/bash
# Automatic hosts file management for internal access

set -e

HOSTS_FILE="/etc/hosts"
BACKUP_FILE="/etc/hosts.backup"
SERVER_IP=$(ip route get 1.1.1.1 | awk '{print $7; exit}')

# List of all domains that should resolve to internal IP
INTERNAL_DOMAINS=(
    "workplace-type-test.prod.kro.kr"
    "work-place-type-test.prod.kro.kr"
    "date-calendar.prod.kro.kr"
    "date-calendar.back-end.kro.kr"
    "exam-world.prod.kro.kr"
    "exam-world.back-end.kro.kr"
    "intranet.prod.kro.kr"
    "intranet.back-end.kro.kr"
    "live-connect.prod.kro.kr"
    "live-connect.back-end.kro.kr"
    "pt-interview.prod.kro.kr"
    "pt-interview.back-end.kro.kr"
    "argocd.shjeon.kro.kr"
    "code-server.shjeon.kro.kr"
    "n8n.shjeon.kro.kr"
    "ai-server.shjeon.kro.kr"
    "ai-server.back-end.kro.kr"
    "exam-world-api.shjeon.kro.kr"
    "syncthing.shjeon.kro.kr"
)

# Function to update hosts file
update_hosts() {
    local current_ip="$1"
    
    echo "$(date): Updating hosts file with IP: $current_ip"
    
    # Create backup
    cp "$HOSTS_FILE" "$BACKUP_FILE"
    
    # Create new hosts file content
    cat > /tmp/hosts_new << EOF
127.0.0.1	localhost
127.0.1.1	shjeon-server

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters

# Added by Docker Desktop
# To allow the same kube context to work on the host and the container:
127.0.0.1	kubernetes.docker.internal
# End of section

# Internal server services - use internal IP to avoid NAT hairpinning issues
# Auto-updated by hosts-manager.sh at $(date)
EOF

    # Add all internal domains with current IP
    for domain in "${INTERNAL_DOMAINS[@]}"; do
        echo "$current_ip $domain" >> /tmp/hosts_new
    done
    
    # Apply new hosts file
    cp /tmp/hosts_new "$HOSTS_FILE"
    rm /tmp/hosts_new
    
    echo "$(date): Hosts file updated successfully"
}

# Function to verify hosts entries
verify_hosts() {
    local failed_domains=()
    
    for domain in "${INTERNAL_DOMAINS[@]}"; do
        resolved_ip=$(getent hosts "$domain" | awk '{print $1}' | head -1)
        if [[ "$resolved_ip" != "$SERVER_IP" ]]; then
            failed_domains+=("$domain")
        fi
    done
    
    if [[ ${#failed_domains[@]} -gt 0 ]]; then
        echo "$(date): WARNING: Some domains are not resolving correctly:"
        printf '%s\n' "${failed_domains[@]}"
        return 1
    else
        echo "$(date): All domains are resolving correctly to $SERVER_IP"
        return 0
    fi
}

# Function to test internal connectivity
test_connectivity() {
    local test_domains=(
        "workplace-type-test.prod.kro.kr"
        "work-place-type-test.prod.kro.kr"
        "argocd.shjeon.kro.kr"
    )
    
    echo "$(date): Testing internal connectivity..."
    
    for domain in "${test_domains[@]}"; do
        if curl -k -s --max-time 5 "https://$domain" > /dev/null; then
            echo "$(date): ✅ $domain - OK"
        else
            echo "$(date): ❌ $domain - FAILED"
        fi
    done
}

# Main execution
case "${1:-check}" in
    "update")
        echo "$(date): Starting hosts file update..."
        update_hosts "$SERVER_IP"
        verify_hosts
        test_connectivity
        ;;
    "verify")
        verify_hosts
        ;;
    "test")
        test_connectivity
        ;;
    "check"|*)
        echo "$(date): Current server IP: $SERVER_IP"
        verify_hosts
        if [[ $? -ne 0 ]]; then
            echo "$(date): Issues detected. Run with 'update' to fix."
        fi
        ;;
esac