provider "aws" {
  region = var.region
}

module "galileo" {
  source = "../."

  create_kms_key            = false
  create_ml_node_group = var.create_ml_node_group
  ml_node_size = var.ml_node_size
  create_rds_postgres_cluster = var.create_rds_postgres_cluster
  postgres_engine_version = var.postgres_engine_version
  postgres_cluster_size = var.postgres_cluster_size
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

