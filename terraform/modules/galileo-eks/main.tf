provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

provider "kubernetes" {
  host                   = module.eks_galileo.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_galileo.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks_galileo.cluster_name, "--region", var.region]
  }
}

data "aws_iam_policy_document" "cluster_autoscaler" {
  statement {
    sid = "ClusterAutoscaler"

    actions = [
      "eks:DescribeNodegroup",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:DescribeScalingActivities",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeTags",
      "ec2:DescribeLaunchTemplateVersions",
      "ec2:DescribeInstanceTypes"
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "cluster_autoscaler" {
  name   = "ClusterAutoscaler_${var.cluster_name}"
  path   = "/"
  policy = data.aws_iam_policy_document.cluster_autoscaler.json
}

module "eks_galileo" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.10.0"

  cluster_name                    = var.cluster_name
  cluster_version                 = var.cluster_version
  cluster_endpoint_private_access = var.cluster_endpoint_private_access
  cluster_endpoint_public_access  = var.cluster_endpoint_public_access

  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs

  cluster_enabled_log_types = var.cluster_enabled_log_types

  cluster_addons = {
    vpc-cni            = {}
    aws-ebs-csi-driver = {}
  }

  create_kms_key            = var.create_kms_key
  cluster_encryption_config = var.cluster_encryption_config
  enable_kms_key_rotation   = var.enable_kms_key_rotation

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_id

  eks_managed_node_groups = merge({
    galileo_core = {
      ami_type                   = "AL2_x86_64"
      instance_types             = ["m5a.xlarge"]
      name                       = "galileo-core"
      use_name_prefix            = false
      use_custom_launch_template = false
      create_launch_template     = false

      disk_size = 200

      min_size     = 2
      max_size     = 5
      desired_size = 3
      labels = {
        galileo-node-type = "galileo-core"
      }

      tags = {
        "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned",
        "k8s.io/cluster-autoscaler/enabled"             = "true",
      }

      max_unavailable = 1

      iam_role_additional_policies = {
        AmazonEKSWorkerNodePolicy          = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
        AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
        ClusterAutoscaler                  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/ClusterAutoscaler_${var.cluster_name}",
        AmazonS3FullAccess                 = "arn:aws:iam::aws:policy/AmazonS3FullAccess",
        AmazonSSMManagedInstanceCore       = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
        CloudWatchAgentServerPolicy        = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
        AmazonEBSCSIDriverPolicy           = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy",
      }
    }

    galileo_runner = {
      ami_type                   = "AL2_x86_64"
      instance_types             = ["m5a.2xlarge"]
      name                       = "galileo-runner"
      use_name_prefix            = false
      use_custom_launch_template = false
      create_launch_template     = false

      disk_size = 200

      min_size     = 1
      max_size     = 5
      desired_size = 1
      labels = {
        galileo-node-type = "galileo-runner"
      }

      tags = {
        "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned",
        "k8s.io/cluster-autoscaler/enabled"             = "true",
      }

      max_unavailable = 1

      iam_role_additional_policies = {
        AmazonEKSWorkerNodePolicy          = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
        AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
        ClusterAutoscaler                  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/ClusterAutoscaler_${var.cluster_name}",
        AmazonS3FullAccess                 = "arn:aws:iam::aws:policy/AmazonS3FullAccess",
        AmazonSSMManagedInstanceCore       = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
        CloudWatchAgentServerPolicy        = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
        AmazonEBSCSIDriverPolicy           = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy",
      }
    }
  }, 
  var.create_ml_node_group ?
    { 
      galileo_ml = {
        ami_type                   = "AL2_x86_64_GPU"
        instance_types             = [var.ml_node_size]
        name                       = "galileo-ml"
        use_name_prefix            = false
        use_custom_launch_template = false
        create_launch_template     = false

        disk_size = 200

        min_size     = 1
        max_size     = 5
        desired_size = 1
        labels = {
          galileo-node-type = "galileo-ml"
        }

        tags = {
          "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned",
          "k8s.io/cluster-autoscaler/enabled"             = "true",
        }

        max_unavailable = 1

        iam_role_additional_policies = {
          AmazonEKSWorkerNodePolicy          = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
          AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
          ClusterAutoscaler                  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/ClusterAutoscaler_${var.cluster_name}",
          AmazonS3FullAccess                 = "arn:aws:iam::aws:policy/AmazonS3FullAccess",
          AmazonSSMManagedInstanceCore       = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
          CloudWatchAgentServerPolicy        = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
          AmazonEBSCSIDriverPolicy           = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy",
        }
      }
    }
  : {} 
  )

  enable_irsa = true
  enable_cluster_creator_admin_permissions = true
}

resource "random_password" "rds" {
  count = var.create_rds_postgres_cluster ? 1 : 0
  length  = 24
  special = false
}

resource "aws_db_subnet_group" "subnet_group" {
  count = var.create_rds_postgres_cluster ? 1 : 0
  name       = "galileo-subnet-group"
  subnet_ids = var.private_subnet_id

  tags = {
    Name = "galileo-subnet-group"
  }
}

resource "aws_rds_cluster" "postgresql" {
  count                     = var.create_rds_postgres_cluster ? 1 : 0
  cluster_identifier        = "galileo-cluster"
  engine                    = "aurora-postgresql"
  engine_version            = var.postgres_engine_version
  db_subnet_group_name      = aws_db_subnet_group.subnet_group[0].name
  database_name             = "galileo"
  engine_mode               = "provisioned"
  vpc_security_group_ids    = [module.eks_galileo.cluster_primary_security_group_id]
  master_username           = "galileordsadmin"
  master_password           = random_password.rds[0].result
  storage_encrypted         = true
  deletion_protection       = true
  backup_retention_period   = 7
  final_snapshot_identifier = "galileo-cluster-final-backup"
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count                = var.create_rds_postgres_cluster ? 1 : 0
  identifier           = "galileo-postgresql-writer"
  cluster_identifier   = aws_rds_cluster.postgresql[0].id
  instance_class       = var.postgres_cluster_size
  engine               = "aurora-postgresql"
  engine_version       = var.postgres_engine_version
  db_subnet_group_name = aws_db_subnet_group.subnet_group[0].name
}

locals {
    database_name = var.create_rds_postgres_cluster ? aws_rds_cluster.postgresql[0].database_name : ""
    write_db_url = var.create_rds_postgres_cluster ? "postgresql+psycopg2://${aws_rds_cluster.postgresql[0].master_username}:${aws_rds_cluster.postgresql[0].master_password}@${aws_rds_cluster.postgresql[0].endpoint}:${aws_rds_cluster.postgresql[0].port}/${local.database_name}" : ""
    read_db_url = var.create_rds_postgres_cluster ? "postgresql+psycopg2://${aws_rds_cluster.postgresql[0].master_username}:${aws_rds_cluster.postgresql[0].master_password}@${aws_rds_cluster.postgresql[0].reader_endpoint}:${aws_rds_cluster.postgresql[0].port}/${local.database_name}" : ""
}

resource "kubernetes_secret" "postgres" {
  count = var.create_rds_postgres_cluster ? 1 : 0
  metadata {
    name = "postgres"
    namespace = "galileo"
  }

  data = {
    GALILEO_POSTGRES_USER = aws_rds_cluster.postgresql[0].master_username
    GALILEO_POSTGRES_PASSWORD = aws_rds_cluster.postgresql[0].master_password
    GALILEO_POSTGRES_REPLICA_PASSWORD = aws_rds_cluster.postgresql[0].master_password
    GALILEO_DATABASE_URL_WRITE = local.write_db_url
    GALILEO_DATABASE_URL_READ = local.read_db_url
  }
}

resource "kubernetes_config_map" "grafana-datasources" {
  count = var.create_rds_postgres_cluster ? 1 : 0
  metadata {
    name = "grafana-datasources"
    namespace = "galileo"
  }

  data      = {
    "datasources.yaml" = <<EOF
apiVersion: 1
datasources:
- access: proxy
  isDefault: true
  name: prometheus
  type: prometheus
  url: "http://prometheus.galileo.svc.cluster.local:9090"
  version: 1
- name: postgres
  type: postgres
  url: "${aws_rds_cluster.postgresql[0].endpoint}:${aws_rds_cluster.postgresql[0].port}"
  database: ${local.database_name}
  user: ${aws_rds_cluster.postgresql[0].master_username}
  secureJsonData:
    password: ${aws_rds_cluster.postgresql[0].master_password}
  jsonData:
    sslmode: "disable"
EOF
  }
}

resource "kubernetes_service_account" "duplo_admin_user" {
  metadata {
    name      = "duplo-admin-user"
    namespace = "kube-system"
  }
}

resource "kubernetes_namespace" "galileo" {
  metadata {
    name = "galileo"
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
    name      = "duplo-admin-user-secret"
    namespace = "kube-system"
    annotations = {
      "kubernetes.io/service-account.name" = "duplo-admin-user"
    }
  }

  type = "kubernetes.io/service-account-token"
}

data "kubernetes_secret" "duplo_admin_user_secret" {
  metadata {
    name      = kubernetes_secret_v1.duplo_admin_user_secret.metadata[0].name
    namespace = "kube-system"
  }
}
