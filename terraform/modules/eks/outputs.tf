# outputs.tf
# Saídas do módulo eks, usadas pelo kubeconfig, ArgoCD (helm) e pelos módulos RDS e ElastiCache

output "cluster_name" {
  description = "Nome do cluster EKS"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "Endpoint da API do Kubernetes"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_certificate_authority" {
  description = "Certificado (base64) da CA do cluster"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}

output "cluster_security_group_id" {
  description = "Security group do cluster, usado para liberar acesso ao RDS e ao Redis"
  value       = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}
