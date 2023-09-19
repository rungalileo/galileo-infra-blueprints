# Steps to setup galileo AKS cluster in azure

1. Clone the terraform repo
```
git clone https://github.com/rungalileo/galileo-infra-blueprints.git
```

2. AKS terraform module is present in the path "terraform/modules/galileo-aks".
```cd terraform/modules/galileo-aks```

3. Follow the instruction in [Terraform Azure Auth guide](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret) link to create service principal for terraform to authenticate to azure


4. Azure Related Environment variables that need to be set. Values will be got from step3 output. Run export command after adding values
```
export ARM_CLIENT_ID=""
export ARM_CLIENT_SECRET=""
export ARM_TENANT_ID=""
export ARM_SUBSCRIPTION_ID=""
```

5. Cluster Customization variables
	- Azure region to create the cluster
	- VNET and subnet Cidr --> Pick a CIDR that dont collide with your existing VNET
	- public_network_access_enabled --> Set this to false if the kubernetes cluster api need to be private. Default is public access enabled.
   Run export command after changes the values
```
export TF_VAR_location="eastus"
export TF_VAR_resource_group_name="galileo"
export TF_VAR_vnet_cidr="10.155.0.0/16"
export TF_VAR_default_subnet_cidr="10.155.0.0/22"
export TF_VAR_public_network_access_enabled="true"
export TF_VAR_resource_prefix="galileo"
```

6. After setting all the above environment variables . We can run "terraform apply" to create the cluster.
```
terraform apply
```

7. Store the state file in the secure place. We will need it for creating kubeconfig.