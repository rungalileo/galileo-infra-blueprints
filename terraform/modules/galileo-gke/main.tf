
locals {
  service_account_iam_binding = ["roles/iam.serviceAccountUser", "roles/iam.serviceAccountTokenCreator"]
  project_iam_binding         = ["roles/container.admin", "roles/container.clusterViewer"]
}

data "google_project" "galileo" {
}

data "google_client_config" "default" {}

resource "google_service_account" "galileoconnect" {
  account_id   = "galileoconnect"
  display_name = "Galileoconnect servcie account"
}

resource "google_service_account_iam_binding" "galileoconnect" {
  count              = length(local.service_account_iam_binding)
  service_account_id = google_service_account.galileoconnect.id
  role               = local.service_account_iam_binding[count.index]

  members = [
    "group:devs@rungalileo.io",
  ]
}

resource "google_project_iam_binding" "galileo" {
  count   = length(local.project_iam_binding)
  project = data.google_project.galileo.project_id
  role    = local.project_iam_binding[count.index]

  members = [
    "serviceAccount:${google_service_account.galileoconnect.email}",
  ]
}

resource "google_iam_workload_identity_pool" "galileoconnectpool" {
  workload_identity_pool_id = "galileoconnectpool"
  display_name              = "GalileoConnectPool"
  description               = "Workload ID Pool for Galileo via GitHub Actions"
  disabled                  = false
}

resource "google_iam_workload_identity_pool_provider" "galileoconnectprovider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.galileoconnectpool.workload_identity_pool_id
  workload_identity_pool_provider_id = "galileoconnectprovider"
  display_name                       = "GalileoConnectProvider"
  disabled                           = false
  attribute_mapping = {
    "google.subject"             = "assertion.sub"
    "attribute.actor"            = "assertion.actor"
    "attribute.aud"              = "assertion.aud"
    "attribute.repository_owner" = "assertion.repository_owner"
    "attribute.repository"       = "assertion.repository"
  }
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

resource "google_service_account_iam_binding" "workloadidentity" {
  service_account_id = google_service_account.galileoconnect.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "principalSet://iam.googleapis.com/projects/${data.google_project.galileo.number}/locations/global/workloadIdentityPools/galileoconnectpool/attribute.repository/rungalileo/deploy",
  ]
}

module "galileo_gke" {
  source                            = "terraform-google-modules/kubernetes-engine/google"
  version                           = "23.3.0"
  project_id                        = data.google_project.galileo.project_id
  name                              = var.cluster_name
  region                            = var.region
  zones                             = var.zones
  network                           = var.network
  subnetwork                        = var.subnetwork
  ip_range_pods                     = var.pods_subnet_name
  ip_range_services                 = var.service_subnet_name
  regional                          = false
  create_service_account            = false
  remove_default_node_pool          = true
  disable_legacy_metadata_endpoints = true
  kubernetes_version                = var.kubernetes_version
  network_policy                    = true
  release_channel                   = "REGULAR"
  enable_shielded_nodes             = true
  horizontal_pod_autoscaling        = true
  http_load_balancing               = true
  filestore_csi_driver              = true
  cluster_autoscaling = {
    enabled       = true
    min_cpu_cores = 0
    max_cpu_cores = 50
    min_memory_gb = 0
    max_memory_gb = 200
    gpu_resources = []
  }

  node_pools = [
    {
      name               = "galileo-core"
      machine_type       = "e2-standard-8"
      image_type         = "COS_CONTAINERD"
      min_count          = 4
      max_count          = 5
      disk_size_gb       = 300
      disk_type          = "pd-standard"
      auto_repair        = true
      auto_upgrade       = true
      initial_node_count = 4
    },
    {
      name               = "galileo-runners"
      machine_type       = "e2-standard-8"
      image_type         = "COS_CONTAINERD"
      min_count          = 1
      max_count          = 3
      disk_size_gb       = 100
      disk_type          = "pd-standard"
      auto_repair        = true
      auto_upgrade       = true
      initial_node_count = 1
    },
  ]

  node_pools_oauth_scopes = {
    galileo-core = [
      "https://www.googleapis.com/auth/devstorage.read_write",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append",
    ]
    galileo-runner = [
      "https://www.googleapis.com/auth/devstorage.read_write",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append",
    ]
  }

  node_pools_labels = {
    galileo-core = {
      galileo-node-type = "galileo-core"
    }
    galileo-runners = {
      galileo-node-type = "galileo-runner"
    }
  }
}
