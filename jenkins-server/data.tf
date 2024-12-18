locals {
    host-config = <<-EOF
#!/bin/bash

sudo apt update -y

# Instaling AWS 
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip
unzip awscliv2.zip
sudo ./aws/install
sudo rm -f awscliv2.zip
sudo ln -svf /usr/local/bin/aws /usr/bin/aws

# Configure aws cli
sudo su -c "aws configure set aws_access_key_id ${aws_iam_access_key.eks_user_key.id}" ubuntu
sudo su -c "aws configure set aws_secret_access_key ${aws_iam_access_key.eks_user_key.secret}" ubuntu
sudo su -c "aws configure set default.region eu-west-2" ubuntu

# Set Access_keys as ENV Variables
export AWS_ACCESS_KEY_ID=${aws_iam_access_key.eks_user_key.id}
export AWS_SECRET_ACCESS_KEY=${aws_iam_access_key.eks_user_key.secret}

# Installing terraform
sudo apt-get update
sudo apt-get install -y wget gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt-get install terraform

# Installing Kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO https://dl.k8s.io/release/v1.29.2/bin/linux/amd64/kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

#

hostnamectl set-hostname cluster-access
EOF
}