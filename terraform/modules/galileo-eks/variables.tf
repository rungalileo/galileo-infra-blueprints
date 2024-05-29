variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-west-2"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "galileo"
}

variable "cluster_version" {
  description = "Kubernetes `<major>.<minor>` version to use for the EKS cluster (i.e.: `1.22`)"
  type        = string
  default     = "1.28"
}

variable "cluster_endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled"
  type        = bool
  default     = false
}

variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC where the cluster and its nodes will be provisioned"
}

variable "private_subnet_id" {
  type        = list(string)
  description = "A list of subnet IDs where the nodes/node groups will be provisioned"
}

variable "cluster_enabled_log_types" {
  description = "A list of the desired control plane logs to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html)"
  type        = list(string)
  default     = ["audit", "api", "authenticator", "controllerManager", "scheduler"]
}

variable "create_kms_key" {
  description = "Controls if a KMS key for cluster encryption should be created"
  type        = bool
  default     = false
}

variable "kms_key_description" {
  description = "The description of the key as viewed in AWS console"
  type        = string
  default     = "Galileo cluster encryption key"
}

variable "enable_kms_key_rotation" {
  description = "Specifies whether key rotation is enabled. Defaults to `true`"
  type        = bool
  default     = true
}

variable "cluster_encryption_config" {
  description = "Configuration block with encryption configuration for the cluster"
  type        = list(any)
  default = [{
    resources = ["secrets"]
  }]
}

variable "create_ml_node_group" {
  description = "Specifies whether create ML/GPU node groups. Defaults to `false`"
  type        = bool
  default     = false
}

variable "ml_node_size" {
  description = "ML/GPU node size. Defaults to `g4dn.2xlarge`"
  type        = string
  default     = "g4dn.2xlarge"
}

variable "create_rds_postgres_cluster" {
  description = "Specifies whether create RDS postgres cluster. Defaults to `true`"
  type        = bool
  default     = true
}


variable "postgres_engine_version" {
  description = "Postgres engine version"
  type        = string
  default     = "16.1"
}

variable "postgres_cluster_size" {
  description = "Postgres aurora cluster instance size"
  type        = string
  default     = "db.t3.medium"
}

