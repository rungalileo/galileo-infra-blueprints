terraform {
  required_version = ">=0.13"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.25.0, < 6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.10"
    }
  }
}
