
# data "terraform_remote_state" "vpc" {
#   count = terraform.workspace == "argocd" || terraform.workspace == "dev" || terraform.workspace == "prod" ? 1 : 0
#   backend = "s3"
#   config = {
#     bucket = "chworkspaces3"
#     key = "eks/terraform.tfstate"
#     dynamodb_table = "chworkspacedb"
#     region = "eu-west-2"
#   }
# }
data "aws_subnet" "shared_private_subnets" {
  for_each = toset([
    "subnet-036abb017e30edb97",
    "subnet-07356fc15def03f5f",
    "subnet-036e024f7f7693281"
  ])

  id = each.value
}

data "aws_vpc" "shared-vpc" {
  id = "vpc-035d4fef6708a3f14"
}
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  # Only deploy in dev, prod, or stage
  count = terraform.workspace == "argocd" || terraform.workspace == "dev" || terraform.workspace == "prod" ? 1 : 0
  cluster_name    = local.name
  cluster_version = "1.27"
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }

  }

  vpc_id                         = data.aws_vpc.shared-vpc.id
  subnet_ids                     = [for subnet in data.aws_subnet.shared_private_subnets : subnet.id]
  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }
      eks_managed_node_groups = {
    one = {
      name = "workernode-${local.name}"

      instance_types = [lookup(var.instance_type, terraform.workspace, "t2.micro")]

      min_size     = 1
      max_size     = 3
      desired_size = 2
    }
  }
  enable_cluster_creator_admin_permissions = true
  tags = {
    Environment = "${terraform.workspace}"
    Terraform = "true"

  }
}


resource "aws_eks_addon" "pod_identity" {
  cluster_name  = data.aws_eks_cluster.current.name
  addon_name    = "eks-pod-identity-agent"
  addon_version = "v1.2.0-eksbuild.1"
}

resource "null_resource" "cluster-config-file" {
  provisioner "local-exec" {
    command     = "aws eks update-kubeconfig --region eu-west-2 --name ${local.name}"
  }
  depends_on = [ module.eks ]
}