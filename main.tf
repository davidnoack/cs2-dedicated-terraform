# Create a new security group
resource "aws_security_group" "cs2_server_sg" {
  name        = "cs2-server-sg"
  description = "Security group for Counter-Strike 2 server"

  # Allow inbound traffic on necessary ports for Counter-Strike
  ingress {
    from_port   = 27015
    to_port     = 27015
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH access for server administration
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH from anywhere for now
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# Read cloud-init configuration from external file
data "template_file" "cloud_init" {
  template = file("init_cloud_config.yaml")
}

# Create a new EC2 instance
resource "aws_instance" "cs2_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro" # Free Tier eligible instance type

  # Associate the security group with the instance
  security_groups = [aws_security_group.cs2_server_sg.name]

  # Use cloud-init for initialization
  user_data = data.template_file.cloud_init.rendered
}

# Allocate a new Elastic IP
resource "aws_eip" "cs2_server_eip" {
  instance = aws_instance.cs2_server.id
}

# Output the public IP address of the Counter-Strike 2 server
output "cs2_server_public_ip" {
  value = aws_instance.cs2_server.public_ip
}