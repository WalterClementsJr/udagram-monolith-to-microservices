variable "cluster_name" {
  description = "Name of the cluster"
  default = "udagram"
}

variable "worker_os" {
  description = "OS to run on worker machines"

  # valid choices are:
  # * ubuntu
  # * centos
  # * coreos
  default = "ubuntu"
}

variable "ssh_public_key_file" {
  description = "SSH public key file"
  default     = "~/.ssh/id_rsa.pub"
}

variable "ssh_port" {
  description = "SSH port to be used to provision instances"
  default     = 22
}

variable "ssh_username" {
  description = "SSH user, used only in output"
  default     = "ubuntu"
}

variable "ssh_private_key_file" {
  description = "SSH private key file used to access instances"
  default     = ""
}

variable "ssh_agent_socket" {
  description = "SSH Agent socket, default to grab from $SSH_AUTH_SOCK"
  default     = "env:SSH_AUTH_SOCK"
}

# Provider specific settings

variable "aws_region" {
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "VPC to use ('default' for default VPC)"
  default     = "default"
}

variable "control_plane_type" {
  description = "AWS instance type"
  default     = "t3.medium"
}

variable "control_plane_volume_size" {
  description = "Size of the EBS volume, in Gb"
  default     = 100
}

variable "worker_type" {
  description = "instance type for workers"
  default     = "t3.medium"
}

variable "ami" {
  description = "AMI ID, use it to fixate control-plane AMI in order to avoid force-recreation it at later times"
  default     = ""
}

