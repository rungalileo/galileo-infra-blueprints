variable "cluster_name" {
  type        = string
  description = "The name of the cluster"
  default     = "galileo"
}

variable "region" {
  type        = string
  description = "The region to host the cluster in"
  default     = "us-central1"
}

variable "zones" {
  type        = list(string)
  description = "The zones to host the cluster in"
  default     = ["us-central1-c"]
}

variable "network" {
  type        = string
  description = "The VPC network to host the cluster in"
}

variable "subnetwork" {
  type        = string
  description = "The subnetwork to host the cluster in"
}

variable "kubernetes_version" {
  type        = string
  description = "The Kubernetes version of the masters"
  default     = "1.23"
}

variable "pod_subnet_name" {
  type        = string
  description = "The name of the secondary subnet ip range to use for pods"
}

variable "service_subnet_name" {
  type        = string
  description = "The name of the secondary subnet range to use for services"
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
