variable "project_id" {
  type        = string
  description = "Google cloud project ID"
}

variable "cluster_name" {
  type        = string
  description = "GKE cluster name"
}

variable "region" {
  type        = string
  description = "Google cloud region"
}

variable "network" {
  type        = string
  description = "The VPC network to host the cluster in"
}

variable "subnetwork" {
  type        = string
  description = "The subnetwork to host the cluster in"
}

variable "pod_subnet_name" {
  type        = string
  description = "The name of the secondary subnet ip range to use for pods"
}

variable "service_subnet_name" {
  type        = string
  description = "The name of the secondary subnet range to use for services"
}

variable "zones" {
  type        = list(string)
  description = "The zones to host the cluster in"
}

variable "kubernetes_version" {
  type        = string
  description = "The Kubernetes version of the masters"
}

variable "create_ml_node_group" {
  description = "Set to true to launch ML node group / workers instances"
  type        = bool
  default     = false
}

variable "ml_node_size" {
  description = "ML/GPU node size. Defaults to `g2-standard-8`"
  type        = string
  default     = "g2-standard-8"
}
