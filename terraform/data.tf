locals {
  az_count         = length(data.aws_availability_zones.available.names)
  az_a             = "${var.aws_region}a"
  az_b             = "${var.aws_region}b"
  az_c             = "${var.aws_region}c"
  kube_cluster_tag = "kubernetes.io/cluster/${var.cluster_name}"
  vpc_id           = var.vpc_id == "default" ? aws_default_vpc.default.id : var.vpc_id

  ami = var.ami == "" ? data.aws_ami.ubuntu.id : var.ami
}

data "aws_availability_zones" "available" {
}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }
}

data "aws_subnet" "az_a" {
  availability_zone = local.az_a
  vpc_id            = local.vpc_id
}

data "aws_subnet" "az_b" {
  availability_zone = local.az_b
  vpc_id            = local.vpc_id
}

data "aws_subnet" "az_c" {
  availability_zone = local.az_c
  vpc_id            = local.vpc_id
}

locals {
  all_subnets = [data.aws_subnet.az_a.id, data.aws_subnet.az_b.id, data.aws_subnet.az_c.id]
}
