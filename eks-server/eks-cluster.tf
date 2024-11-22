module "eks" {
  source  = "terraform-aws-modules/eks/aws"

  cluster_name    = lookup(var.cluster-name, terraform.workspace, "default")
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

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }
      eks_managed_node_groups = {
    one = {
      name = "worker-node-1"

      instance_types = [lookup(var.instance_type, terraform.workspace, "t2.micro")]

      min_size     = 1
      max_size     = 3
      desired_size = 2
    }
    
    two = {
      name = "worker-node-2"

      instance_types = [lookup(var.instance_type, terraform.workspace, "t2.micro")]

      min_size     = 1
      max_size     = 2
      desired_size = 1
    }
  }
  tags = {
    Environment = "${terraform.workspace}"
    Terraform = "true"

  }
}