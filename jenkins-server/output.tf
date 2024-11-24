output "jenkins-ip" {
    value = aws_instance.cluster-host.public_ip
}