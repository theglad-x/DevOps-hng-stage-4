
# Define the VPC
resource "aws_vpc" "todo_app_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "todo Application-vpc"
  }
}

# create public subnet
resource "aws_subnet" "todo_app_public_subnet" {
  vpc_id                  = aws_vpc.todo_app_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"

  tags = {
    Name = "todo Application-subnet"
  }
}

# create internet gateway
resource "aws_internet_gateway" "todo_igw" {
  vpc_id = aws_vpc.todo_app_vpc.id

  tags = {
    Name = "todo_igw"
  }
}

# create route table
resource "aws_route_table" "todo_route_table" {
  vpc_id = aws_vpc.todo_app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.todo_igw.id
  }
}

# associate route table with subnet
resource "aws_route_table_association" "todo_route_assoc" {
  subnet_id      = aws_subnet.todo_app_public_subnet.id
  route_table_id = aws_route_table.todo_route_table.id
}

# create security group
resource "aws_security_group" "todo_sg" {
  vpc_id      = aws_vpc.todo_app_vpc.id
  description = "Allow traffic from the internet,SSH and traefik"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "todo Application-sg"
  }
}

# create ec2 instance
resource "aws_instance" "todo_server" {
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.todo_app_public_subnet.id
  vpc_security_group_ids      = [aws_security_group.todo_sg.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size = 16
    volume_type = "gp2"
  }

  tags = {
    Name = "todo_instance"
  }

  # Wait for the instance to be fully available before proceeding
  provisioner "remote-exec" {
    inline = ["echo 'Your server is ready!'"]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }
}

# Create Route53 record for the domain
resource "aws_route53_record" "domain" {
  count   = var.domain_name != "" ? 1 : 0
  zone_id = var.route53_zone_id
  name    = var.domain_name
  type    = "A"
  ttl     = 300
  records = [aws_instance.todo_server.public_ip]
}

# Create subdomains for the APIs
resource "aws_route53_record" "auth_subdomain" {
  count   = var.domain_name != "" ? 1 : 0
  zone_id = var.route53_zone_id
  name    = "auth.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.todo_server.public_ip]
}

resource "aws_route53_record" "todos_subdomain" {
  count   = var.domain_name != "" ? 1 : 0
  zone_id = var.route53_zone_id
  name    = "todos.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.todo_server.public_ip]
}

resource "aws_route53_record" "users_subdomain" {
  count   = var.domain_name != "" ? 1 : 0
  zone_id = var.route53_zone_id
  name    = "users.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.todo_server.public_ip]
}

# Generate Ansible inventory file
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/templates/inventory.tmpl", {
    ip_address   = aws_instance.todo_server.public_ip
    ssh_user     = "ubuntu"
    ssh_key_file = var.private_key_path
    domain_name  = var.domain_name
    admin_email  = var.admin_email
  })
  filename = "${path.module}/ansible/inventory/hosts.yml"

  depends_on = [aws_instance.todo_server]
}

# Generate Ansible variables file
resource "local_file" "ansible_vars" {
  content = templatefile("${path.module}/templates/vars.tmpl", {
    domain_name  = var.domain_name
    admin_email  = var.admin_email
    git_repo_url = var.git_repo_url
    git_branch   = var.git_branch
  })
  filename = "${path.module}/ansible/vars/main.yml"

  depends_on = [aws_instance.todo_server]
}

# Run Ansible playbook
resource "null_resource" "ansible_provisioner" {
  triggers = {
    instance_id = aws_instance.todo_server.id
  }

  provisioner "local-exec" {
    command = "cd ${path.module}/ansible && ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory/hosts.yml playbook.yml -vvv"
  }

  depends_on = [local_file.ansible_inventory, local_file.ansible_vars]
}
