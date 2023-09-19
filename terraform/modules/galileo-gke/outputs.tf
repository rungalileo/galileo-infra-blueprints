output "cluster_id" {
  description = "Cluster ID"
  value       = module.galileo_gke.cluster_id
}

output "node_pools_names" {
  description = "List of node pools names"
  value       = module.galileo_gke.node_pools_names
}

output "endpoint" {
  sensitive   = true
  description = "Cluster endpoint"
  value       = module.galileo_gke.endpoint
}

output "ca_certificate" {
  sensitive   = true
  description = "Cluster ca certificate (base64 encoded)"
  value       = module.galileo_gke.ca_certificate
}

output "admin_token" {
  sensitive   = true
  description = "admin-token"
  value = lookup(data.kubernetes_secret.duplo_admin_user_secret.data, "token")
}
