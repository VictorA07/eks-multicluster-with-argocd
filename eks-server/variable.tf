variable "instance_type" {
  description = "Instance types based on workspace"
  type        = map(string)
  default     = {
    argocd = "t2.medium"
    dev   = "t3.medium"
    prod = "t3.medium"
  }
}

variable "cluster-name" {
  description = "cluster name based on workspace"
  type        = map(string)
  default     = {
    argocd = "argocd-cluster"
    dev   = "dev-cluster"
    prod = "prod-cluster"
  }
}

variable "target-argocd" {
  description = "The cluster to deploy argocd resource to"
  type        = string
  default     = "argocd-cluster" 
}