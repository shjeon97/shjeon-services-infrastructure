# 🚀 Shjeon Services Infrastructure

K3s 기반 GitOps 인프라스트럭처 관리 리포지토리

## 📁 구조

```
shjeon-services-infrastructure/
├── argocd/                     # ArgoCD 설정
│   ├── ingress.yaml
│   ├── certificate.yaml
│   ├── github-repo-config.yaml
│   └── application-template.yaml
├── applications/               # 애플리케이션 매니페스트
│   ├── workplace-type-test/
│   ├── work-place-type-test/
│   ├── exam-world/
│   ├── pt-interview/
│   ├── date-calendar/
│   ├── live-connect/
│   └── intranet/
├── cert-manager/              # 인증서 관리
├── istio/                     # 서비스 메시
├── monitoring/                # 모니터링 도구
├── security/                  # 보안 정책
└── traefik/                   # Ingress Controller
```

## 🌐 배포된 서비스

- **ArgoCD**: https://argocd.shjeon.kro.kr
- **Workplace Type Test**: https://workplace-type-test.prod.kro.kr
- **Work Place Type Test**: https://work-place-type-test.prod.kro.kr

## 🔐 ArgoCD 접속 정보

- **URL**: https://argocd.shjeon.kro.kr
- **Username**: admin
- **Password**: [관리자에게 문의]

## 📝 사용법

1. **새 애플리케이션 추가**
   ```bash
   mkdir -p applications/my-new-app
   # deployment.yaml, service.yaml, ingress.yaml 작성
   ```

2. **ArgoCD 애플리케이션 생성**
   ```bash
   kubectl apply -f argocd/application-template.yaml
   ```

3. **GitHub에 푸시**
   ```bash
   git add .
   git commit -m "Add new application"
   git push origin main
   ```

## 🔄 GitOps 워크플로우

1. 개발자가 애플리케이션 매니페스트를 수정
2. GitHub에 푸시
3. ArgoCD가 자동으로 변경사항 감지
4. K3s 클러스터에 자동 배포

## 🛠️ 관리 명령어

```bash
# ArgoCD 상태 확인
kubectl get pods -n argocd

# 애플리케이션 동기화 상태 확인
kubectl get applications -n argocd

# 인증서 상태 확인
kubectl get certificates --all-namespaces
```