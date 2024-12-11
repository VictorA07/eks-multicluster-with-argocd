#Aws loadbalncer controler for nginx

#retriving account id
data "aws_caller_identity" "current" {}


resource "aws_iam_policy" "aws-lb-controler-policy" {
  name = "AWSlbController"
  policy = file("values/aws-lb-controler-policy.json")
}
module "irsa_aws_lb_controler" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"

  create_role = true
  role_name   = "irsa_aws_lb_controler-role-${terraform.workspace}"

  provider_url = data.aws_eks_cluster.current.identity[0].oidc[0].issuer

  role_policy_arns = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/AWSlbController"  # Replace with your desired policy
  ]

  tags = {
    Environment = terraform.workspace
  }

  oidc_fully_qualified_subjects = [
    "system:serviceaccount:kube-system:aws-load-balancer-controller"
  ]
  depends_on = [ module.eks, aws_iam_policy.aws-lb-controler-policy]
}

resource "kubernetes_service_account" "aws-load-balancer-controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = module.irsa_aws_lb_controler.iam_role_arn
    }
  }
  depends_on = [ module.eks ]
}

resource "helm_release" "aws-load-balancer-controller" {
  name = "aws-load-balancer-controller"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.4.1"

  set {
    name  = "clusterName"
    value = local.name
  }

  set {
    name  = "image.tag"
    value = "v2.10.1"
  }
    set {
    name  = "serviceAccount.create"
    value = "false" # We assume IRSA is being used and the SA is pre-created
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller" # Replace with your ServiceAccount name
  }
  depends_on = [
    module.eks,
    module.irsa_aws_lb_controler
  ]
}

locals {
  name = "eks-${terraform.workspace}"
}