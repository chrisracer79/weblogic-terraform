
# VPC CIDR block
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}
# region is used to specify the AWS region to use
variable "region" {
    default = "us-east-1"
}

# Map of availability zones
variable "zones" {
  type = "map"

  default = {
    us-east-1 = ["us-east-1a", "us-east-1b"]
    us-west-2 = ["us-west-1a", "us-west-1b"]
  }
}

variable "bastion_zone_indices" {
  default = [0, 1]
}

# SSH public key to use when bootstrapping new EC2 instances
variable "bootstrap-pub-sshkey-path" {
  default = "~/.ssh/aws_rsa.pub"
}

# Default AMI image used in this demonstration
# Must change the image if you use a region other than US-EAST-1
variable "default_ami" {
  # Using Amazon Linux image

  default = {
    us-east-1 = "ami-0ff8a91507f77f867"
  }
}


