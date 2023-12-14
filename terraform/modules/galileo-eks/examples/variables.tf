variable "environment" {
  description = "The deployment environment (e.g., staging, production)"
  type        = string

  validation {
    condition     = contains(["staging"], var.environment)
    error_message = "The environment must be either 'staging' or 'production'."
  }
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-west-2"
}
