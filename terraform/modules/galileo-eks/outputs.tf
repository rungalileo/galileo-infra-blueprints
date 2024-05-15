output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = module.eks_galileo.cluster_arn
}

output "cluster_certificate_authority_data" {
  sensitive   = true
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks_galileo.cluster_certificate_authority_data
}

output "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = module.eks_galileo.cluster_endpoint
}

output "cluster_id" {
  description = "The name/id of the EKS cluster"
  value       = module.eks_galileo.cluster_id
}

output "cluster_version" {
  description = "The Kubernetes version for the cluster"
  value       = module.eks_galileo.cluster_version
}

output "eks_managed_node_groups" {
  description = "Map of attribute maps for all EKS managed node groups created"
  value       = module.eks_galileo.eks_managed_node_groups
}

output "admin_token" {
  sensitive   = true
  description = "admin-token"
  value       = lookup(data.kubernetes_secret.duplo_admin_user_secret.data, "token")
}