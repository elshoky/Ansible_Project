provider "aws" {
  region = "us-east-2"  # Changed region to us-east-2
}

data "aws_ami" "ubuntu-linux-image" {
  most_recent = true
  owners      = ["099720109477"]  # Ubuntu account ID for AMIs

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]  # Ubuntu 20.04
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

output "ubuntu_ami_id" {
  value = data.aws_ami.ubuntu-linux-image.id
}

resource "aws_vpc" "app-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
      Name = "${var.environment_prefix}-vpc"
  }
}

resource "aws_subnet" "app-subnet-1" {
  vpc_id = aws_vpc.app-vpc.id
  cidr_block = var.subnet_1_cidr_block
  availability_zone = var.availability_zone
  tags = {
      Name = "${var.environment_prefix}-subnet-1"
  }
}

resource "aws_security_group" "app-security-group" {
  name   = "app-security-group"
  vpc_id = aws_vpc.app-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name = "${var.environment_prefix}-security-group"
  }
}

resource "aws_internet_gateway" "app-internet-gateway" {
  vpc_id = aws_vpc.app-vpc.id

  tags = {
    Name = "${var.environment_prefix}-internet-gateway"
  }
}

resource "aws_route_table" "app-route-table" {
  vpc_id = aws_vpc.app-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app-internet-gateway.id
  }

  tags = {
    Name = "${var.environment_prefix}-route-table"
  }
}

# Associate subnet with Route Table
resource "aws_route_table_association" "subnet-route-association" {
  subnet_id      = aws_subnet.app-subnet-1.id
  route_table_id = aws_route_table.app-route-table.id
}

output "application_server_ip" {
  value = aws_instance.app-server.public_ip
}

resource "aws_instance" "app-server" {
  ami                         = data.aws_ami.ubuntu-linux-image.id
  instance_type               = var.instance_type
  key_name                    = "your_key_name"  # Update your key name here
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.app-subnet-1.id
  vpc_security_group_ids      = [aws_security_group.app-security-group.id]
  availability_zone           = var.availability_zone

  tags = {
    Name = "${var.environment_prefix}-server"
  }

  provisioner "local-exec" {
    command = "ansible-playbook --inventory ${self.public_ip}, --private-key ${var.ssh_key} --user ubuntu playbook.yaml" 
  }
}
