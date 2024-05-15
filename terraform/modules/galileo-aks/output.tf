output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.aks_galileo.cluster_ca_certificate
  sensitive   = true
}

output "cluster_endpoint" {
  description = "Hostname for your Kubernetes API server"
  value       = module.aks_galileo.host
  sensitive   = true
}

output "client_key" {
  description = "Client key for your Kubernetes API server"
  value       = module.aks_galileo.client_key
  sensitive   = true
}

output "client_certificate" {
  description = "Client certificate for your Kubernetes API server"
  value       = module.aks_galileo.client_certificate
  sensitive   = true
}