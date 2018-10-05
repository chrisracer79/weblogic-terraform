/* 

Module: weblogic_terraform

Author: Christopher Parent <chris@chrisparent.io>
Copyright 2018

Purpose: 
This Terraform code will create a 3-tier network deployment that can be used for hosting highly available WebLogic-based deployments. 
The following elements are created:

- Dedicated virtual private cloud in an AWS region
- Public subnets containing public edge servics: bastion host, Internet Gateway, NAT Gateway, Public Load Balancer
- Private subnets for hosting WebLogic application servers and Oracle database
- Network ACLs and security group rules for restricting network traffic 


How to use:

1. Create a public/private SSH keypair to be used to bootstrap the EC2 instances created here. 
2. Update the variables.tf to use your AWS public ssh key
3. Create an AWS credentials file containing an AWS access key and secret key ID. This is used to authenticate against AWS.
4. Run terraform plan and terraform apply to create the infrastructure and computing resources
5. Run terraform destroy to destroy all the resources created

How to access EC2 instances

Access to any instance created in this terraform must go through the bastion server that is created. There are two ways to access EC2 instances in a private subnet:

Option 1: SSH into bastion, then ssh into private EC2 instance. This requires copying around your SSH private key, which is a bad practice. This option is not recommended.

Option 2: Configure SSH ProxyCommand in your SSH config. This allows you to use the bastion as a proxy server which will allow you to access private EC2 instances directly from your workstation.


*/

# Configure the AWS provider

provider "aws" {
  region = "${var.region}"
}

resource "aws_vpc" "weblogic_vpc" {
    cidr_block       = "${var.vpc_cidr}"
    enable_dns_hostnames = false
    tags {
        Name = "WLS VPC"
  }
}

resource "aws_key_pair" "deployer-keypair" {
  key_name = "bootstrap-key"
  public_key = "${file("${var.bootstrap-pub-sshkey-path}")}"
}




