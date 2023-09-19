output "admin_token" {
  sensitive   = true
  description = "admin token"
  value       = module.galileo.admin_token
}

output "cluster_certificate_authority_data" {
  sensitive   = true
  description = "cluster certificate authority data"
  value       = module.galileo.cluster_certificate_authority_data
}

output "cluster_endpoint" {
  description = "cluster endpoint"
  value       = module.galileo.cluster_endpoint
}

output "cluster_arn" {
  description = "cluster arn"
  value       = module.galileo.cluster_arn
}