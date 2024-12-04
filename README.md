# eks-multicluster-with-argocd

### The goal of this project is to manage a hub-spoke cluster with argocd

we are deploying 3 clusters, 1 to host argocd and the other to host the dev/stage and production environment

ArgoCD target
create and deploy using helm chart
create and deply using kustomise
create and deploy using argocd Applicationn and ApplicationSet
stored secret using vault
dynamic variable in helm
managing multiple helm


## to apply setup.sh run the below script
chmod +x apply_all.sh
./apply_all.sh


## Challenges
Having issue in connecting to cluster to install terraform helm (argocd and istio) while running locally
- decide to set up and configure an instance to setup the cluster

- not able to deploy cluster after inporting vpc tfstate
Error refreshing state: unsupported checkable object kind "var"
resolutions: it works after upgrading terraform

-Error:Unable to find remote state
Resolutions:

## how to get argocd password


sudo su -c "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode > /home/ubuntu/argocdpassword" ubuntu

#Login into argocd userinterface via argocd cli
argocd login $ARGOCD_DOMAIN --username admin --password $ARGOCD_PASSWORD --insecure

#Creating Argocd variable
ARGOCD_PASSWORD=$(</home/ubuntu/argocdpassword)


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.5"

  [..]

  access_entries = {
    my_entry = {
      kubernetes_groups = []
      principal_arn     = local.my_role_arn

      policy_associations = {
        cluster = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }



      -------------------------
      dynamic block in terraform

      resource "aws_security_group" "example" {
  name = "example-sg"

  dynamic "ingress" {
    for_each = [
      { from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["10.0.0.0/16"] },
      { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }
    ]
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
}
