variable "instance_type" {
  description = "Instance types based on workspace"
  type        = map(string)
  default     = {
    argocd = "t2.medium"
    dev   = "t3.medium"
    prod = "t3.medium"
  }
}


variable "target-argocd" {
  description = "The cluster to deploy argocd resource to"
  type        = string
  default     = "eks-argocd" 
}