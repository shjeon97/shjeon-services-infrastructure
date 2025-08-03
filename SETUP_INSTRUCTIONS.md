# 🔧 Setup Instructions

## GitHub Repository Configuration

### 1. Configure GitHub Personal Access Token

Edit the ArgoCD repository configuration:

```bash
kubectl edit secret github-repo-creds -n argocd
```

Replace the password field with your GitHub Personal Access Token:
- Token must have `repo` and `read:org` scopes
- Generate at: https://github.com/settings/tokens

### 2. Apply Repository Configuration

```bash
# Replace GITHUB_TOKEN with your actual token
sed 's/REPLACE_WITH_GITHUB_TOKEN/YOUR_ACTUAL_TOKEN/g' \
  argocd/github-repo-config.yaml | kubectl apply -f -
```

### 3. Verify Repository Connection

```bash
kubectl get applications -n argocd
kubectl describe application workplace-type-test -n argocd
```

## ArgoCD Access

- **URL**: https://argocd.shjeon.kro.kr
- **Username**: admin  
- **Password**: shjeon0528

## GitOps Workflow

1. Make changes to application manifests
2. Commit and push to GitHub
3. ArgoCD automatically detects changes
4. Applications are synced to K3s cluster

## Security Notes

- Never commit actual tokens to git
- Use Kubernetes secrets for sensitive data
- Rotate tokens regularly
- Monitor access logs