data "aws_acm_certificate" "argocd-cert" {
  domain = "hullerdata.com"
  most_recent = true
}

#Argocd template values

resource "kubernetes_ingress" "argocd_ingress" {
  metadata {
    name      = "argocd-ingress"
    namespace = "argocd"
    annotations = {
      "nginx.ingress.kubernetes.io/ssl-redirect"     = "false"
      "nginx.ingress.kubernetes.io/backend-protocol" = "HTTP"
    }
  }

  spec {
    rule {
      http {
        path {
          path     = "/"

          backend {
            service_name = "argocd-server"
            service_port = 80
          }
        }
      }

      host = "argocd.hullerdata.com" # Replace with your domain
    }
  }
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
  
  values = [file("values/metric-server.yml")]
  depends_on = [ module.eks ]
}




resource "null_resource" "password" {
  provisioner "local-exec" {
    #working_dir = "./argocd"
    command     = "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath={.data.password} | base64 -d > argocd-login.txt"
  }
  depends_on = [ helm_release.argocd ]
}