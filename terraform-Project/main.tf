# 1. Specify the Terraform Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

# 2. Virtual Private Cloud
resource "aws_vpc" "flask_application_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "flask-app-vpc"
  }
}

# 3. Public Subnet for the Web Server
resource "aws_subnet" "flask_public_subnet" {
  vpc_id                  = aws_vpc.flask_application_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "flask-app-public-subnet"
  }
}

# 4. Internet Gateway
resource "aws_internet_gateway" "flask_internet_gateway" {
  vpc_id = aws_vpc.flask_application_vpc.id

  tags = {
    Name = "flask-app-igw"
  }
}

# 5. Route Table
resource "aws_route_table" "flask_public_route_table" {
  vpc_id = aws_vpc.flask_application_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.flask_internet_gateway.id
  }

  tags = {
    Name = "flask-app-public-rt"
  }
}

# 6. Route Table Association
resource "aws_route_table_association" "flask_public_association" {
  subnet_id      = aws_subnet.flask_public_subnet.id
  route_table_id = aws_route_table.flask_public_route_table.id
}

# 7. Security Group (Allows Flask on Port 80 and SSH on Port 22)
resource "aws_security_group" "flask_security_group" {
  name        = "flask-app-security-group"
  description = "Allow inbound SSH and HTTP traffic for Flask"
  vpc_id      = aws_vpc.flask_application_vpc.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP traffic for Flask"
    from_port   = 80
    to_port     = 80
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
    Name = "flask-app-sg"
  }
}

# 8. AWS Key Pair
resource "aws_key_pair" "flask_ssh_key" {
  key_name   = "flask-app-deployer-key"
  public_key = file(pathexpand("~/.ssh/id_rsa.pub"))
}

# 9. EC2 Instance with Provisioners
resource "aws_instance" "flask_web_instance" {
  ami                    = "ami-01a00762f46d584a1" # Ubuntu 22.04 LTS
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.flask_public_subnet.id
  vpc_security_group_ids = [aws_security_group.flask_security_group.id]
  key_name               = aws_key_pair.flask_ssh_key.key_name

  # Provisioner 1: Create the directory on the remote machine
  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/ubuntu/flask_app"
    ]
  }

  # Provisioner 2: Push your local application files to the instance
  # Change source path to your local project folder (e.g., "./app.py" or "./my_flask_project")
  provisioner "file" {
    source      = "./app.py"
    destination = "/home/ubuntu/flask_app/app.py"
  }

  # Provisioner 3: Install dependencies and start the app via SSH execution
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install python3-pip python3-venv -y",
      "cd /home/ubuntu/flask_app",
      "python3 -m venv venv",
      "./venv/bin/pip install flask",
      # Runs the app with root privileges to bind to port 80 in the background
      "sudo /home/ubuntu/flask_app/venv/bin/python3 app.py > flask.log 2>&1 &",
      "sleep 2" # Gives the process a moment to initialize before closing the connection
    ]
  }

  # Connection block telling the provisioners how to log into the VM
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(pathexpand("~/.ssh/id_rsa")) # Path to your matching local private key
    host        = self.public_ip
  }

  tags = {
    Name = "flask-web-server"
  }
}

# 10. Output URL to access the live Flask App
output "flask_app_url" {
  description = "The HTTP URL to view your Flask application"
  value       = "http://${aws_instance.flask_web_instance.public_ip}"
}
