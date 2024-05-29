variable "environment" {
  description = "The deployment environment (e.g., staging, production)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "The environment must be either 'dev', 'staging' or 'production'."
  }
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-west-2"
}

variable "create_ml_node_group" {
  description = "Set to true to launch ML node group / workers instances"
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
