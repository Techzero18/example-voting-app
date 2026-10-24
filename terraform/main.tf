data "aws_vpc" "default" {
  default = true
}
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "tls_private_key" "ssh_key" {
  algorithm = "ED25519"
}
resource "aws_key_pair" "generated_key" {
  key_name   = "capstone-k8s-key-v2"
  public_key = tls_private_key.ssh_key.public_key_openssh
}
resource "local_file" "private_key" {
  content  = tls_private_key.ssh_key.private_key_openssh
  filename = "capstone-key.pem"
}

resource "aws_security_group" "k8s_sg" {
  name        = "capstone-k8s-sg"
  vpc_id      = data.aws_vpc.default.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "k3s_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.small"

  root_block_device {
    volume_size = 20
  }

  subnet_id              = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [aws_security_group.k8s_sg.id]
  key_name               = aws_key_pair.generated_key.key_name

  user_data = <<-EOF
              #!/bin/bash
              sudo fallocate -l 4G /swapfile
              sudo chmod 600 /swapfile
              sudo mkswap /swapfile
              sudo swapon /swapfile
              curl -sfL https://get.k3s.io | sh -
              sudo chmod 644 /etc/rancher/k3s/k3s.yaml
              EOF

  tags = {
    Name = "Capstone-Kubernetes-Node"
  }
}

output "ssh_command" {
  value = "ssh -i capstone-key.pem ubuntu@${aws_instance.k3s_server.public_dns}"
}