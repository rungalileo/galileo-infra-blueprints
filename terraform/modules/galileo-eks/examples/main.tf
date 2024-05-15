provider "aws" {
  region = var.region
}

module "galileo" {
  source = "../."

  create_kms_key            = false
  cluster_encryption_config = []

  vpc_id = aws_vpc.vpc.id
  private_subnet_id = [
    aws_subnet.public_subnet_a.id,
    aws_subnet.private_subnet_a.id,
    aws_subnet.public_subnet_b.id,
    aws_subnet.private_subnet_b.id,
    aws_subnet.public_subnet_c.id,
    aws_subnet.private_subnet_c.id
  ]
}

