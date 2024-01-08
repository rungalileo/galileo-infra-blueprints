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
    args        = ["eks", "get-token", "--cluster-name", module.eks_galileo.cluster_id]
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
  version = "~> 18.0"

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

  eks_managed_node_groups = {
    galileo_core = {
      ami_type               = "AL2_x86_64"
      instance_types         = ["m5a.xlarge"]
      name                   = "galileo-core"
      use_name_prefix        = false
      create_launch_template = false
      launch_template_name   = ""

      disk_size = 200

      min_size     = 4
      max_size     = 6
      desired_size = 5
      labels = {
        galileo-node-type = "galileo-core"
      }

      tags = {
        "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned",
        "k8s.io/cluster-autoscaler/enabled"             = "true",
      }

      max_unavailable = 1

      iam_role_attach_cni_policy = true

      iam_role_additional_policies = [
        "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
        "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/ClusterAutoscaler_${var.cluster_name}",
        "arn:aws:iam::aws:policy/AmazonS3FullAccess",
        "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
        "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
        "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy",
      ]

    }

    galileo_runner = {
      ami_type               = "AL2_x86_64"
      instance_types         = ["m5a.xlarge"]
      name                   = "galileo-runner"
      use_name_prefix        = false
      create_launch_template = false
      launch_template_name   = ""

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

      iam_role_attach_cni_policy = true

      iam_role_additional_policies = [
        "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
        "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/ClusterAutoscaler_${var.cluster_name}",
        "arn:aws:iam::aws:policy/AmazonS3FullAccess",
        "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
        "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
        "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy",
      ]
    }
  }

  manage_aws_auth_configmap = true
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

