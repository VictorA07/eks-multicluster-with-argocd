
module "irsa_s3_access" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"

  create_role = true
  role_name   = "irsa-s3-access-role-${terraform.workspace}"

  provider_url = data.aws_eks_cluster.current.identity[0].oidc[0].issuer

  role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"  # Replace with your desired policy
  ]

  tags = {
    Environment = terraform.workspace
  }

  oidc_fully_qualified_subjects = [
    "system:serviceaccount:default:my-service-account"
  ]
  depends_on = [ module.eks ]
}

resource "kubernetes_service_account" "s3_access" {
  metadata {
    name      = "my-service-account"
    namespace = "default"
    annotations = {
      "eks.amazonaws.com/role-arn" = module.irsa_s3_access.iam_role_arn
    }
  }
  depends_on = [ module.eks ]
}