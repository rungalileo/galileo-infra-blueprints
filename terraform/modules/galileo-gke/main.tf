
locals {
  service_account_iam_binding = ["roles/iam.serviceAccountUser", "roles/iam.serviceAccountTokenCreator"]
  project_iam_binding         = ["roles/container.admin", "roles/container.clusterViewer"]
}

data "google_project" "galileo" {
}

data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.galileo_gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.galileo_gke.ca_certificate)
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
  ip_range_pods                     = var.pod_subnet_name
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
      machine_type       = "e2-standard-4"
      image_type         = "COS_CONTAINERD"
      min_count          = 2
      max_count          = 5
      disk_size_gb       = 300
      disk_type          = "pd-standard"
      auto_repair        = true
      auto_upgrade       = true
      initial_node_count = 3
    },
    {
      name               = "galileo-runners"
      machine_type       = "e2-standard-8"
      image_type         = "COS_CONTAINERD"
      min_count          = 1
      max_count          = 5
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


resource "kubernetes_service_account" "duplo_admin_user" {
  metadata {
    name = "duplo-admin-user"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role_binding" "duplo_admin_user_binding" {
  metadata {
    name = "duplo-admin-user-cluster-admin-new-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "duplo-admin-user"
    namespace = "kube-system"
  }
}

resource "kubernetes_secret_v1" "duplo_admin_user_secret" {
  metadata {
    name = "duplo-admin-user-secret"
    namespace = "kube-system"
    annotations = {
      "kubernetes.io/service-account.name" = "duplo-admin-user"
    }
  }

  type = "kubernetes.io/service-account-token"
}

data "kubernetes_secret" "duplo_admin_user_secret" {
  metadata {
    name = kubernetes_secret_v1.duplo_admin_user_secret.metadata[0].name
    namespace = "kube-system"
  }
}
