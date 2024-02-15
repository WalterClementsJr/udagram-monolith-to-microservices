provider "aws" {
  region = var.aws_region
}

resource "aws_default_vpc" "default" {
}

resource "aws_key_pair" "deployer" {
  key_name   = "${var.cluster_name}-deployer-key"
  public_key = file(var.ssh_public_key_file)
}

resource "aws_security_group" "common" {
  name   = "${var.cluster_name}-common"
  vpc_id = local.vpc_id

  tags = tomap({
    (local.kube_cluster_tag) = "shared"
  })

  ingress {
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "control_plane" {
  name        = "${var.cluster_name}-control_planes"
  description = "cluster control_planes"
  vpc_id      = local.vpc_id

  tags = tomap({
    (local.kube_cluster_tag) = "shared"
  })

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "role" {
  name = "${var.cluster_name}-host"

  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "",
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "ec2.amazonaws.com"
          },
          "Action" : "sts:AssumeRole"
        }
      ]
    }
  )
}

resource "aws_iam_instance_profile" "profile" {
  name = "${var.cluster_name}-host"
  role = aws_iam_role.role.name
}

resource "aws_iam_role_policy" "policy" {
  name = "${var.cluster_name}-host"
  role = aws_iam_role.role.id

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : ["ec2:*"],
          "Resource" : ["*"]
        },
        {
          "Effect" : "Allow",
          "Action" : ["elasticloadbalancing:*"],
          "Resource" : ["*"]
        }
      ]
    })

}

resource "aws_lb" "control_plane" {
  name               = "${var.cluster_name}-api-lb"
  internal           = false
  load_balancer_type = "network"
  subnets            = local.all_subnets
  tags               = tomap({
    "Cluster"                = var.cluster_name
    (local.kube_cluster_tag) = "shared"
  })
}

resource "aws_lb_target_group" "control_plane_api" {
  name     = "${var.cluster_name}-api"
  port     = 6443
  protocol = "TCP"
  vpc_id   = local.vpc_id
}

resource "aws_lb_listener" "control_plane_api" {
  load_balancer_arn = aws_lb.control_plane.arn
  port              = 6443
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_lb_target_group.control_plane_api.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group_attachment" "control_plane_api" {
  count            = 3
  target_group_arn = aws_lb_target_group.control_plane_api.arn
  target_id        = element(aws_instance.control_plane.*.id, count.index)
  port             = 6443
}

resource "aws_instance" "control_plane" {
  count = 3

  tags = tomap(
    {
      "Name"                   = "${var.cluster_name}-control_plane-${count.index + 1}"
      (local.kube_cluster_tag) = "shared"
    }
  )

  instance_type          = var.control_plane_type
  iam_instance_profile   = aws_iam_instance_profile.profile.name
  ami                    = local.ami
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.common.id, aws_security_group.control_plane.id]
  availability_zone      = data.aws_availability_zones.available.names[count.index % local.az_count]
  subnet_id              = local.all_subnets[count.index % local.az_count]
  ebs_optimized          = true

  root_block_device {
    volume_type = "gp2"
    volume_size = var.control_plane_volume_size
  }
}
