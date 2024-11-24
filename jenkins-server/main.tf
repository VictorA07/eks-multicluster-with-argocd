# RSA key of size 4096 bits
resource "tls_private_key" "keypair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "keypair" {
  content         = tls_private_key.keypair.private_key_pem
  filename        = "cluster-host.pem"
  file_permission = "600"
}

resource "aws_key_pair" "public-key" {
  key_name   = "cluster-host"
  public_key = tls_private_key.keypair.public_key_openssh
}

# Creating remote server
resource "aws_instance" "cluster-host" {
  ami                         = "ami-0e5f882be1900e43b"
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.cluster-access-sg.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.cluster-host-profile.id
  key_name                    = aws_key_pair.public-key.id
  user_data                   = local.host-config

  tags = {
    Name = "cluster-host"
  }
}

# Create null resource to copy playbooks directory into ansible server
resource "null_resource" "copy-eks-file" {
  connection {
    type        = "ssh"
    host        = aws_instance.cluster-host.public_ip
    user        = "ubuntu"
    private_key = tls_private_key.keypair.private_key_pem
  }
  provisioner "file" {
    source      = "./cloud-folder"
    destination = "/home/ubuntu/cluster-setup"
  }
}

# Create IAM User
resource "aws_iam_user" "eks_user" {
  name = "eks_user"
}

# Create IAM Access Key
resource "aws_iam_access_key" "eks_user_key" {
  user = aws_iam_user.eks_user.name
}

# Create IAM Group
resource "aws_iam_group" "eks_group" {
  name = "eks_group"
}

# Add ansible user to terraform group
resource "aws_iam_user_group_membership" "eks_group_membership" {
  user   = aws_iam_user.eks_user.name
  groups = [aws_iam_group.eks_group.name]
}

# Create IAM Policy
resource "aws_iam_group_policy_attachment" "eks_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  group      = aws_iam_group.eks_group.name
}

#  Create IAM Policy
resource "aws_iam_role_policy_attachment" "cluster-host-policy-attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = aws_iam_role.cluster-host-role.name
}

# Create IAM Role
resource "aws_iam_role" "cluster-host-role" {
  name               = "cluster-host-role"
  assume_role_policy = file("${path.root}/iam-role.json")
}

# Create IAM Instance Profile
resource "aws_iam_instance_profile" "cluster-host-profile" {
  name = "cluster-host-profile"
  role = aws_iam_role.cluster-host-role.name
}

# Create security group Load balancer
resource "aws_security_group" "cluster-access-sg" {
  tags = {
    Name = "cluster-access-sg"
  }
}

resource "aws_security_group_rule" "allow-ingress-remote-host-sg" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.cluster-access-sg.id
}

resource "aws_security_group_rule" "egress-all-remote-host-sg" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.cluster-access-sg.id
}