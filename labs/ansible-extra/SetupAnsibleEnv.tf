provider "aws" {
  region = "us-west-1"
}

variable "number_of_students" {
  description = "Number of students"
  default     = 1   
}

variable "base_ami" {
  description = "AMI to start from"
  default     = "ami-07013dd48140efd73"
}

# Create a new non-default VPC
resource "aws_vpc" "custom_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "CustomVPC"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "custom_igw" {
  vpc_id = aws_vpc.custom_vpc.id

  tags = {
    Name = "CustomIGW"
  }
}

# Route Table
resource "aws_route_table" "custom_route_table" {
  vpc_id = aws_vpc.custom_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.custom_igw.id
  }

  tags = {
    Name = "CustomRouteTable"
  }
}

# Route Table Association
resource "aws_route_table_association" "custom_subnet_association" {
  subnet_id      = aws_subnet.custom_subnet.id
  route_table_id = aws_route_table.custom_route_table.id
}

# Subnet with Public IP Assignment
resource "aws_subnet" "custom_subnet" {
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "CustomSubnet"
  }
}

# Create a security group in the new VPC
resource "aws_security_group" "ssh_and_web_access" {
  vpc_id      = aws_vpc.custom_vpc.id
  name        = "ssh_and_web_access"
  description = "Allow SSH, web (HTTP/HTTPS), and RDP inbound traffic"

  ingress {
    description      = "SSH Access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTP Access"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTPS Access"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SSH and Web Access Security Group"
  }
}

# Generate a key pair
resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "default" {
  key_name   = "dynamic_key_pair"
  public_key = tls_private_key.example.public_key_openssh
}

resource "local_file" "private_key" {
  filename = "dynamic_key.pem"
  content  = tls_private_key.example.private_key_pem
}

# Copy the PEM file to the control node
resource "null_resource" "copy_pem_file" {
  provisioner "file" {
    source      = "dynamic_key.pem"
    destination = "/home/ubuntu/dynamic_key.pem"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(local_file.private_key.filename)
      host        = aws_instance.control_node[0].public_ip
    }
  }

  depends_on = [local_file.private_key, aws_instance.control_node]
}

# Generate inventory files for each student
resource "local_file" "generate_inventory" {
  count = var.number_of_students

  filename = "inventory_${count.index + 1}"
  content  = <<-EOT
[control]
controlnode ansible_host=${aws_instance.control_node[count.index].public_ip}

[webservers]
targetnode1 ansible_host=${aws_instance.target_node[count.index * 2].public_ip}
targetnode2 ansible_host=${aws_instance.target_node[count.index * 2 + 1].public_ip}
EOT
}

# Copy inventory files to control nodes
resource "null_resource" "copy_inventory_files" {
  count = var.number_of_students

  provisioner "file" {
    source      = local_file.generate_inventory[count.index].filename
    destination = "/home/ubuntu/inventory"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(local_file.private_key.filename)
      host        = aws_instance.control_node[count.index].public_ip
    }
  }

  depends_on = [local_file.generate_inventory]
}

# Install PuTTYgen, clone repo, convert key, and run Ansible
resource "null_resource" "setup_control_node" {
  count = var.number_of_students

  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install -y putty-tools ansible git",
      "git clone https://github.com/ProDataMan/Ansible-Intro.git || true", # Avoid error if already cloned
      "puttygen /home/ubuntu/dynamic_key.pem -o /home/ubuntu/dynamic_key.ppk",
      "ANSIBLE_HOST_KEY_CHECKING=False ansible -m ping all -i /home/ubuntu/inventory",
      "ansible-playbook Ansible-Intro/webservers.yml -i /home/ubuntu/inventory"
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(local_file.private_key.filename)
      host        = aws_instance.control_node[count.index].public_ip
    }
  }

  depends_on = [
    null_resource.copy_inventory_files,
    null_resource.copy_pem_file
  ]
}

# Download the PPK file to the machine running Terraform
resource "null_resource" "download_ppk_file" {
  provisioner "local-exec" {
    command = <<EOT
      scp -o StrictHostKeyChecking=no -i dynamic_key.pem ubuntu@${aws_instance.control_node[0].public_ip}:/home/ubuntu/dynamic_key.ppk dynamic_key.ppk
    EOT
  }

  depends_on = [null_resource.setup_control_node]
}

# Create control node instances
resource "aws_instance" "control_node" {
  count = var.number_of_students

  ami                    = var.base_ami
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.default.key_name
  vpc_security_group_ids = [aws_security_group.ssh_and_web_access.id]
  subnet_id              = aws_subnet.custom_subnet.id

  tags = {
    Name = "Student-${count.index + 1}-ControlNode"
  }
}

# Create target node instances
resource "aws_instance" "target_node" {
  count = var.number_of_students * 2

  ami                    = var.base_ami
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.default.key_name
  vpc_security_group_ids = [aws_security_group.ssh_and_web_access.id]
  subnet_id              = aws_subnet.custom_subnet.id

  tags = {
    Name = "Student-${count.index / 2 + 1}-TargetNode-${count.index % 2 + 1}"
  }
}
