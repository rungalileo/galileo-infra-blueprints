provider "aws" {}

module "galileo" {
  source = "../."

  create_kms_key            = false
  cluster_encryption_config = []

  vpc_id            = var.vpc_id
  private_subnet_id = var.private_subnet_id

}
