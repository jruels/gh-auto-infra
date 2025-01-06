

resource "aws_instance" "web" {
  ami           = "ami-031af0979071399d0"
  instance_type = var.instance_type
  user_data_replace_on_change = true
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.web.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y nginx
              echo "<h1>Welcome to the GitHub Actions & Terraform Lab!!</h1>" > /var/www/html/index.html
              systemctl enable nginx
              systemctl start nginx
              EOF

  tags = merge(var.project_tags, {
    Name = "web-server"
  })
}
