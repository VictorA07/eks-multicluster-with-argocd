# eks-multicluster-with-argocd

### The goal of this project is to manage a hub-spoke cluster with argocd

we are deploying 3 clusters, 1 to host argocd and the other to host the dev/stage and production environment

ArgoCD target
create and deploy using helm chart
create and deply using kustomise
create and deploy using argocd Applicationn and ApplicationSet
stored secret using vault

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