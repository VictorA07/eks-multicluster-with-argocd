output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value = length(module.eks) > 0 ? module.eks[0].cluster_endpoint : null
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value = length(module.eks) > 0 ? module.eks[0].cluster_name : null
}
