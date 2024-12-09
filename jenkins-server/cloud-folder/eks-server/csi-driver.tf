module "irsa_csi_access" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"

  create_role = true
  role_name   = "irsa-csi-access-role-${terraform.workspace}"

  provider_url = data.aws_eks_cluster.current.identity[0].oidc[0].issuer

  role_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"  # Replace with your desired policy
  ]

  tags = {
    Environment = terraform.workspace
  }

  oidc_fully_qualified_subjects = [
    "system:serviceaccount:kube-system:ebs-csi-controller-sa"
  ]
  depends_on = [ module.eks ]
}

resource "kubernetes_service_account" "csi_access" {
  metadata {
    name      = "ebs-csi-controller-sa"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = module.irsa_csi_access.iam_role_arn
    }
  }
  depends_on = [ module.eks ]
}