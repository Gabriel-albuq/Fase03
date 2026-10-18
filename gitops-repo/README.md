# ToggleMaster GitOps Repository

Repositório com as definições declarativas para deploy dos microsserviços do ToggleMaster via GitOps.

## 🚀 Como usar

### ArgoCD

```bash
# Criar Application
kubectl apply -f applications/auth-service-app.yaml

# Sync via CLI
argocd app sync auth-service
```

### 🔐 Segredos (External Secrets)

```bash
# Os valores ficam no AWS Secrets Manager (criados pelo Terraform)
# O ExternalSecret de cada serviço só referencia o nome do segredo
kubectl apply -f infrastructure/cluster-secret-store.yaml

# Conferir se o Secret foi criado
kubectl get externalsecret -n auth-service
```

## 🔄 Workflow GitOps

1. **Desenvolvedor** faz mudança no código
2. **CI Pipeline** builda nova imagem
3. **Pipeline** atualiza tag no GitOps repo
4. **GitOps Agent** detecta mudança
5. **Deploy** automático no cluster

## 📊 Ambientes

- **Production**: Namespace `auth-service`

## 🏷️ Convenções

### Tags de Imagem
- `v1.0.0-<sha7>` - Imagem gerada pelo CI a cada push na main (7 primeiros caracteres do commit)

### Labels
- `app`: Nome da aplicação
- `environment`: Ambiente (production)
- `managed-by`: Ferramenta GitOps (gitops)
