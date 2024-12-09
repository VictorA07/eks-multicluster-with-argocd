data "aws_acm_certificate" "argocd-cert" {
  domain = "hullerdata.com"
  most_recent = true
}

#Argocd template values

data "template_file" "argocd_values" {
  template = <<-EOF
    server:
      service:
        type: LoadBalancer
        annotations:
          service.beta.kubernetes.io/aws-load-balancer-type: nlb
          service.beta.kubernetes.io/aws-load-balancer-arn: "${data.aws_lb.ingress-nginx.arn}"
          service.beta.kubernetes.io/aws-load-balancer-scheme: internet-facing
          service.beta.kubernetes.io/aws-load-balancer-ssl-cert: "${data.aws_acm_certificate.argocd-cert.arn}"
          service.beta.kubernetes.io/aws-load-balancer-ssl-ports: "443"
          service.beta.kubernetes.io/aws-load-balancer-backend-protocol: http
  EOF
  depends_on = [ helm_release.ingress_nginx ]
}



# helm install argocd -n argocd --create-namespace argo/argo-cd --version 7.3.11 -f terraform/values/argocd.yaml
resource "helm_release" "argocd" {
  count = terraform.workspace == "argocd" ? 1 : 0
  name = "argocd"

  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "7.3.11"

  set {
    name  = "server.service.type"
    value = "LoadBalancer"
  }
  values = [
    data.template_file.argocd_values.rendered
  ]
  depends_on = [ module.eks ]
}




resource "null_resource" "password" {
  provisioner "local-exec" {
    #working_dir = "./argocd"
    command     = "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath={.data.password} | base64 -d > argocd-login.txt"
  }
  depends_on = [ helm_release.argocd ]
}