provider "aws" {}

module "galileo" {
  source = "../."

  create_kms_key            = false
  cluster_encryption_config = []

  vpc_id            = "vpc-d49621bf"
  private_subnet_id = ["subnet-8109d6ea", "subnet-726e123e", "subnet-d18b9eab"]

  galileo_connect_role_arn = "arn:aws:iam::818240400754:role/Galileo"
}
