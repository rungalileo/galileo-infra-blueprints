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


data "aws_iam_policy_document" "galileo_policy" {
  statement {
    sid = "galileoPolicy"

    actions = [
      "eks:AccessKubernetesApi",
      "eks:DescribeCluster",
    ]

    resources = [
      "arn:aws:eks:${var.region}:${data.aws_caller_identity.current.account_id}:cluster/${var.cluster_name}",
    ]
  }
}

data "aws_iam_policy_document" "cluster_autoscaler" {
  statement {
    sid = "ClusterAutoscaler"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeScalingActivities",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "eks:DescribeNodegroup",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "cluster_autoscaler" {
  name   = "ClusterAutoscaler"
  path   = "/"
  policy = data.aws_iam_policy_document.cluster_autoscaler.json
}

resource "aws_iam_policy" "galileo" {
  name   = "Galileo"
  path   = "/"
  policy = data.aws_iam_policy_document.galileo_policy.json
}

resource "aws_iam_role" "galileo" {
  name = "Galileo"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : [
            "arn:aws:iam::273352303610:role/GalileoConnect"
          ],
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "galileo" {
  role       = aws_iam_role.galileo.name
  policy_arn = aws_iam_policy.galileo.arn
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
        "k8s.io/cluster-autoscaler/CLUSTER_NAME" = "owned",
        "k8s.io/cluster-autoscaler/enabled"      = "true",
      }

      max_unavailable = 1

      iam_role_attach_cni_policy = true

      iam_role_additional_policies = [
        "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
        "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/ClusterAutoscaler",
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
        "k8s.io/cluster-autoscaler/CLUSTER_NAME" = "owned",
        "k8s.io/cluster-autoscaler/enabled"      = "true",
      }

      max_unavailable = 1

      iam_role_attach_cni_policy = true

      iam_role_additional_policies = [
        "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
        "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/ClusterAutoscaler",
        "arn:aws:iam::aws:policy/AmazonS3FullAccess",
        "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
        "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
        "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy",
      ]
    }
  }

  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      rolearn  = "${aws_iam_role.galileo.arn}"
      username = "Galileo"
      groups   = ["system:masters"]
    },
  ]
}
