provider "aws" {
    region = "eu-central-1"
}

data "aws_vpc" "lesson7_couga_vpc" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.lesson7_couga_vpc.id
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name = "name"

    values = [
      "amzn-ami-hvm-*-x86_64-gp2",
    ]
  }

  filter {
    name = "owner-alias"

    values = [
      "amazon",
    ]
  }
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "lesson7-security"
  description = "Security group"
  vpc_id      = data.aws_vpc.lesson7_couga_vpc.id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "all-icmp"]
  egress_rules        = ["all-all"]
}

resource "aws_network_interface" "this" {
  count = 1
  subnet_id = tolist(data.aws_subnet_ids.all.ids)[count.index]
}

module "ec2_cluster" {
  source = "terraform-aws-modules/ec2-instance/aws"

  instance_count = 1

  name          = "lesson7-couga"
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  subnet_id     = tolist(data.aws_subnet_ids.all.ids)[0]
  vpc_security_group_ids      = [module.security_group.this_security_group_id]
  associate_public_ip_address = true


  root_block_device = [
    {
      volume_type = "gp2"
      volume_size = 8
    }
  ]
}