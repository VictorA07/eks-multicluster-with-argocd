
# provider "helm" {
#   kubernetes {
#     config_path = "~/.kube/config"
#   }
# }
# INSTALLiNG ISTIO

# helm repo add istio https://istio-release.storage.googleapis.com/charts
# helm repo update
# helm install my-istio-base-release -n istio-system --create-namespace istio/base --set global.istioNamespace=istio-system
resource "kubernetes_namespace" "istio_system" {
  metadata {
    name = "istio-system"
  }
}
resource "kubernetes_namespace" "istio_ingress" {
  metadata {
    name = "istio-ingress"
    labels = {
      "istio-injection" : "enabled"
    }
  }
}

resource "helm_release" "istio_base" {
  name = "my-istio-base-release"

  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "base"
  namespace       = kubernetes_namespace.istio_system.metadata.0.name
  create_namespace = true
  cleanup_on_fail = true
  version          = "1.17.1"

  set {
    name  = "global.istioNamespace"
    value = "istio-system"
  }
  depends_on = [ module.eks, kubernetes_namespace.istio_system ]
}

# helm repo add istio https://istio-release.storage.googleapis.com/charts
# helm repo update
# helm install my-istiod-release -n istio-system --create-namespace istio/istiod --set telemetry.enabled=true --set global.istioNamespace=istio-system
resource "helm_release" "istiod" {
  name = "my-istiod-release"

  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "istiod"
  namespace       = kubernetes_namespace.istio_system.metadata.0.name
  create_namespace = true
  cleanup_on_fail = true
  version          = "1.17.1"

  set {
    name  = "telemetry.enabled"
    value = "true"
  }

  set {
    name  = "global.istioNamespace"
    value = "istio-system"
  }

  set {
    name  = "meshConfig.ingressService"
    value = "istio-gateway"
  }

  set {
    name  = "meshConfig.ingressSelector"
    value = "gateway"
  }

  depends_on = [helm_release.istio_base, kubernetes_namespace.istio_system]
}

# helm repo add istio https://istio-release.storage.googleapis.com/charts
# helm repo update
# helm install gateway -n istio-ingress --create-namespace istio/gateway
resource "helm_release" "gateway" {
  name = "gateway"

  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "gateway"
  namespace       = kubernetes_namespace.istio_ingress.metadata.0.name
  cleanup_on_fail = true
  create_namespace = true
  version          = "1.17.1"
  timeout = 500

  depends_on = [kubernetes_namespace.istio_ingress, helm_release.istiod]

}