# Fetch the latest Bitnami Tomcat AMI
data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["bitnami-tomcat-*-x86_64-hvm-ebs-nami"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["979382823631"] # Bitnami
}

# Fetch the default VPC
data "aws_vpc" "default" {
  default = true
}

# Create a new EC2 instance with the specified AMI and instance type
resource "aws_instance" "blog" {
  ami           = data.aws_ami.app_ami.id
  instance_type = var.instance_type

  vpc_security_group_ids = [module.blog_sg.security_group_id]

  tags = {
    Name = "Learning Terraform"
  }
}

# Use a security group module to manage ingress and egress rules
module "blog_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.13.0"

  name   = "blog_new"
  vpc_id = data.aws_vpc.default.id

  # Specify proper ingress rules (HTTP and HTTPS)
  ingress_rules        = ["http-80-tcp", "https-443-tcp"]
  ingress_cidr_blocks  = ["0.0.0.0/0"]

  # Allow all outbound traffic
  egress_rules         = ["all-all"]
  egress_cidr_blocks   = ["0.0.0.0/0"]
}

# Optional: Remove the manually defined security group if redundant with module
# Uncomment if needed, or ensure no duplicate security groups exist.
# resource "aws_security_group" "blog" {
#   name        = "blog"
#   description = "Allow http and https in. Allow everything out"
#   vpc_id      = data.aws_vpc.default.id 
# }

# Comment out redundant manually defined security group rules if using module
# resource "aws_security_group_rule" "blog_http_in" {
#   type              = "ingress"
#   from_port         = 80
#   to_port           = 80
#   protocol          = "tcp"
#   cidr_blocks       = ["0.0.0.0/0"]
#   security_group_id = aws_security_group.blog.id
# }

# resource "aws_security_group_rule" "blog_https_in" {
#   type              = "ingress"
#   from_port         = 443
#   to_port           = 443
#   protocol          = "tcp"
#   cidr_blocks       = ["0.0.0.0/0"]
#   security_group_id = aws_security_group.blog.id
# }

# resource "aws_security_group_rule" "blog_everything_out" {
#   type              = "egress"
#   from_port         = 0
#   to_port           = 0
#   protocol          = -1
#   cidr_blocks       = ["0.0.0.0/0"]
#   security_group_id = aws_security_group.blog.id
# }
