variable "instance_type" {
  description = "Instance types based on workspace"
  type        = map(string)
  default     = {
    argocd = "t2.medium"
    dev   = "t3.medium"
    prod = "t3.medium"
  }
}


