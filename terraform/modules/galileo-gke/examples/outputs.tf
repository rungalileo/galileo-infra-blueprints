output "admin_token" {
  sensitive   = true
  description = "admin-token"
  value       = module.galileo.admin_token
}

output "cluster_name" {
  description = "GKE cluster name"
  value       = var.cluster_name
}

output "ca_certificate" {
  sensitive   = true
  description = "ca_certificate"
  value       = module.galileo.ca_certificate
}

output "cluster_endpoint" {
  sensitive   = true
  description = "cluster-endpoint"
  value       = module.galileo.endpoint
}