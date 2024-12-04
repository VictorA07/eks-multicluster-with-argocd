# helm install argocd -n argocd --create-namespace argo/argo-cd --version 7.3.11 -f terraform/values/argocd.yaml
resource "helm_release" "argocd" {
  count = var.target-argocd == "eks-argocd" ? 1 : 0
  name = "argocd"

  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "7.3.11"

  values = [file("values/argocd.yml")]
}

variable "target-argocd" {
  description = "The cluster to deploy argocd resource to"
  type        = string
  default     = "eks-argocd" 
}