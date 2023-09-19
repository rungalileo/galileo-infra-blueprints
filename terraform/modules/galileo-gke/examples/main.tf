data "google_client_config" "default" {}

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "kubernetes" {
  host                   = "https://${module.galileo.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.galileo.ca_certificate)
}

module "galileo" {
  source              = "../"
  cluster_name        = var.cluster_name
  network             = var.network
  subnetwork          = var.subnetwork
  pod_subnet_name     = var.pod_subnet_name
  service_subnet_name = var.service_subnet_name
  kubernetes_version = var.kubernetes_version
  zones = var.zones
}
