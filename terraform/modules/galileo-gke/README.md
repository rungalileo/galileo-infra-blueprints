# Galileo terraform GKE cluster

Terraform module which creates GKE and IAM resources requred to deploy Galileo.

## Prerequisites

- Enabling services as referenced here https://cloud.google.com/migrate/containers/docs/config-dev-env#enabling_required_services"
- VPC network with secondary IP address range (`pods_subnet_name`, `service_subnet_name`) https://cloud.google.com/kubernetes-engine/docs/concepts/alias-ips

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=0.13 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.36.0, < 5.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.10 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 4.36.0, < 5.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_galileo_gke"></a> [galileo\_gke](#module\_galileo\_gke) | terraform-google-modules/kubernetes-engine/google | 23.3.0 |

## Resources

| Name | Type |
|------|------|
| [kubernetes_service_account.duplo_admin_user](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [kubernetes_cluster_role_binding.duplo_admin_user_binding](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding) | resource |
| [kubernetes_secret_v1.duplo_admin_user_secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [google_service_account_iam_binding.workloadidentity](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_binding) | resource |
| [google_client_config.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |
| [google_project.galileo](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the cluster | `string` | `"galileo"` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | The Kubernetes version of the masters | `string` | `"1.23"` | no |
| <a name="input_network"></a> [network](#input\_network) | The VPC network to host the cluster in | `string` | n/a | yes |
| <a name="input_pods_subnet_name"></a> [pods\_subnet\_name](#input\_pods\_subnet\_name) | The name of the secondary subnet ip range to use for pods | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region to host the cluster in | `string` | `"us-central1"` | no |
| <a name="input_service_subnet_name"></a> [service\_subnet\_name](#input\_service\_subnet\_name) | The name of the secondary subnet range to use for services | `string` | n/a | yes |
| <a name="input_subnetwork"></a> [subnetwork](#input\_subnetwork) | The subnetwork to host the cluster in | `string` | n/a | yes |
| <a name="input_zones"></a> [zones](#input\_zones) | The zones to host the cluster in | `list(string)` | <pre>[<br>  "us-central1-c"<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ca_certificate"></a> [ca\_certificate](#output\_ca\_certificate) | Cluster ca certificate (base64 encoded) |
| <a name="admin_token"></a> [admin\_token](#output\_admin\_token) | Cluster admin token |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | Cluster ID |
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | Cluster endpoint |
| <a name="output_node_pools_names"></a> [node\_pools\_names](#output\_node\_pools\_names) | List of node pools names |
<!-- END_TF_DOCS -->