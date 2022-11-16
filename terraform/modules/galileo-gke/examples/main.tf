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
  network             = "default"
  subnetwork          = "default"
  pods_subnet_name    = "gke-pod"
  service_subnet_name = "gke-svc"
}
