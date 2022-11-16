# Galileo terraform modules

This section contains the galileo terraform modules for EKS and GKE.

# Usage

There are examples included in each module folder but simple usage is as follows:


### `galileo-eks`
```
provider "aws" {}

module "galileo" {
  source = "git@github.com:rungalileo/galileo-infra-blueprints.git//terraform/modules/galileo-eks"

  create_kms_key            = false
  cluster_encryption_config = []

  vpc_id            = "vpc-12345"
  private_subnet_id = ["subnet-0123456", "subnet-789012"]

}

```

### `galileo-gke`
```
data "google_client_config" "default" {}

provider "google" {
  project = "<PROJECT ID>"
  region  = "us-central1"
}

provider "kubernetes" {
  host                   = "https://${module.galileo.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.galileo.ca_certificate)
}

module "galileo" {
  source              = "git@github.com:rungalileo/galileo-infra-blueprints.git//terraform/modules/galileo-gke"
  network             = "default"
  subnetwork          = "default"
  pod_subnet_name     = "galileo-pod"
  service_subnet_name = "galileo-svc"
}
```