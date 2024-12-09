resource "helm_release" "ingress_nginx" {
  name = "ingress-nginx"

  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  version          = "4.4.0"

  set {
    name  = "controller.ingressClassResource.name"
    value = "external-ingress-nginx"
  }

  set {
    name  = "controller.metrics.enabled"
    value = "true"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
    value = "nlb"
  }
  depends_on = [ module.eks ]
}


# Get DNS name of the ELB created by the Ingress Controller.
data "kubernetes_service" "ingress-nginx" {
  metadata {
    namespace = "ingress-nginx"
    name = "ingress-nginx-controller"
  }

  depends_on = [helm_release.ingress_nginx]

}

data "aws_lb" "ingress-nginx" {
  name = regex(
    "(^[^-]+)",
    data.kubernetes_service.ingress-nginx.status[0].load_balancer[0].ingress[0].hostname
  )[0]
# name = data.kubernetes_service.ingress-nginx.status[0].load_balancer[0].ingress[0].hostname
}
