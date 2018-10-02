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
    cidr_block       = "10.0.0.0/16"
    enable_dns_hostnames = false
    tags {
        Name = "WLS VPC"
  }
}

resource "aws_subnet" "public_edge_1" {
    vpc_id = "${aws_vpc.weblogic_vpc.id}"

    cidr_block = "10.0.1.0/28"

    # Use first AZ in region
    availability_zone = "${element(var.zones[var.region],0)}"

    map_public_ip_on_launch = "true"

    tags {
        Name = "Public Subnet"
    }
}
resource "aws_subnet" "public_edge_2" {
    vpc_id = "${aws_vpc.weblogic_vpc.id}"

    cidr_block = "10.0.2.0/28"

    # Use first AZ in region
    availability_zone = "${element(var.zones[var.region],1)}"

    map_public_ip_on_launch = "true"

    tags {
        Name = "Public Subnet"
    }
}


resource "aws_subnet" "app_1" {
    vpc_id = "${aws_vpc.weblogic_vpc.id}"

    cidr_block = "10.0.100.0/28"

    # Use first AZ in region
    availability_zone = "${element(var.zones[var.region],0)}"

    tags {
        Name = "Prviate app subnet"
    }
}

resource "aws_subnet" "app_2" {
    vpc_id = "${aws_vpc.weblogic_vpc.id}"

    cidr_block = "10.0.101.0/28"

    # Use first AZ in region
    availability_zone = "${element(var.zones[var.region],1)}"

    tags {
        Name = "Prviate app subnet"
    }
}

resource "aws_subnet" "data_1" {
    vpc_id = "${aws_vpc.weblogic_vpc.id}"

    cidr_block = "10.0.102.0/28"

    # Use first AZ in region
    availability_zone = "${element(var.zones[var.region],0)}"

    tags {
        Name = "Prviate DB subnet"
    }
}
resource "aws_subnet" "data_2" {
    vpc_id = "${aws_vpc.weblogic_vpc.id}"

    cidr_block = "10.0.103.0/28"

    # Use first AZ in region
    availability_zone = "${element(var.zones[var.region],1)}"

    tags {
        Name = "Prviate DB subnet"
    }
}


# Public Network ACL rules
resource "aws_network_acl" "public_nacl" {
  vpc_id = "${aws_vpc.weblogic_vpc.id}"

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }
# Allow for return traffic from Internet Gateway
ingress {
    protocol   = "tcp"
    rule_no    = 400
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }
  
  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }


  tags {
    Name = "WLS public edge tier"
  }

  # Apply to our public subnets
  subnet_ids = ["${aws_subnet.public_edge_1.id}", "${aws_subnet.public_edge_2.id}"]

}

# Network ACLs for  application tier
resource "aws_network_acl" "weblogic_nacl" {
  vpc_id = "${aws_vpc.weblogic_vpc.id}"

  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  egress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = "${aws_vpc.weblogic_vpc.cidr_block}"
    from_port  = 1521
    to_port    = 1521
  }
  # Egress for NAT
  egress {
    protocol   = "tcp"
    rule_no    = 400
    action     = "allow"
    cidr_block = "${aws_vpc.weblogic_vpc.cidr_block}"
    from_port  = 0
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "${aws_vpc.weblogic_vpc.cidr_block}"
    from_port  = 80
    to_port    = 80
  }
  
  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "${aws_vpc.weblogic_vpc.cidr_block}"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = "${aws_vpc.weblogic_vpc.cidr_block}"
    from_port  = 443
    to_port    = 443
  }

    # Weblogic admin console
    ingress {
        protocol   = "tcp"
        rule_no    = 400
        action     = "allow"
        cidr_block = "${aws_vpc.weblogic_vpc.cidr_block}"
        from_port  = 7001
        to_port    = 7001
    }

    ingress {
        protocol   = "tcp"
        rule_no    = 500
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = 1024
        to_port    = 65535
    }

  tags {
    Name = "Private WLS app tier"
  }

  # Apply to private  app subnets
  subnet_ids = ["${aws_subnet.app_1.id}", "${aws_subnet.app_2.id}"]

}

# Database tier network rules
resource "aws_network_acl" "data_nacl" {
  vpc_id = "${aws_vpc.weblogic_vpc.id}"

  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  # Default Oracle DB listener port
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "${aws_vpc.weblogic_vpc.cidr_block}"
    from_port  = 1521
    to_port    = 1521
  }
  
  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "${aws_vpc.weblogic_vpc.cidr_block}"
    from_port  = 22
    to_port    = 22
  }

  # For EM console if needed
  ingress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = "${aws_vpc.weblogic_vpc.cidr_block}"
    from_port  = 443
    to_port    = 443
  }

  tags {
    Name = "Private WLS Database tier rules"
  }

  # Apply to private data subnets
  subnet_ids = ["${aws_subnet.data_1.id}", "${aws_subnet.data_2.id}"]

}


resource "aws_internet_gateway" "igw" {
     vpc_id = "${aws_vpc.weblogic_vpc.id}"
}

resource "aws_eip" "nat_eip" {
    vpc      = true
}
resource "aws_nat_gateway" "ngw" {
  allocation_id = "${aws_eip.nat_eip.id}"
  subnet_id     = "${aws_subnet.public_edge_1.id}"

  depends_on = ["aws_internet_gateway.igw"]
}

resource "aws_route_table" "public_route" {
  vpc_id = "${aws_vpc.weblogic_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }


  tags {
    Name = "Public route to internet"
  }
}

resource "aws_route_table" "private_route" {
  vpc_id = "${aws_vpc.weblogic_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.ngw.id}"
  }

  tags {
    Name = "Private route to NAT"
  }
}

resource "aws_route_table_association" "edge1" {
  subnet_id      = "${aws_subnet.public_edge_1.id}"
  route_table_id = "${aws_route_table.public_route.id}"
}
resource "aws_route_table_association" "edge2" {
  subnet_id      = "${aws_subnet.public_edge_2.id}"
  route_table_id = "${aws_route_table.public_route.id}"
}

resource "aws_route_table_association" "app1" {
  subnet_id      = "${aws_subnet.app_1.id}"
  route_table_id = "${aws_route_table.private_route.id}"
}
resource "aws_route_table_association" "app2" {
  subnet_id      = "${aws_subnet.app_2.id}"
  route_table_id = "${aws_route_table.private_route.id}"
}

resource "aws_route_table_association" "db1" {
  subnet_id      = "${aws_subnet.data_1.id}"
  route_table_id = "${aws_route_table.private_route.id}"
}

resource "aws_route_table_association" "db2" {
  subnet_id      = "${aws_subnet.data_2.id}"
  route_table_id = "${aws_route_table.private_route.id}"
}

resource "aws_security_group_rule" "allow_ssh" {
  type            = "ingress"
  from_port       = 22
  to_port         = 22
  protocol        = "tcp"
  cidr_blocks     = ["0.0.0.0/0"]
  
  security_group_id = "${aws_vpc.weblogic_vpc.default_security_group_id}"
}

resource "aws_security_group_rule" "allow_http" {
  type            = "ingress"
  from_port       = 80
  to_port         = 80
  protocol        = "tcp"
  cidr_blocks     = ["0.0.0.0/0"]
  
  security_group_id = "${aws_vpc.weblogic_vpc.default_security_group_id}"
}

resource "aws_security_group_rule" "allow_https" {
  type            = "ingress"
  from_port       = 443
  to_port         = 443
  protocol        = "tcp"
  cidr_blocks     = ["0.0.0.0/0"]
  
  security_group_id = "${aws_vpc.weblogic_vpc.default_security_group_id}"
}

resource "aws_security_group_rule" "allow_all_out_to_nat" {
  type            = "egress"
  from_port       = 0
  to_port         = 65535
  protocol        = "tcp"
  self            = "true"
  
  security_group_id = "${aws_vpc.weblogic_vpc.default_security_group_id}"
}

resource "aws_key_pair" "deployer-keypair" {
  key_name = "bootstrap-key2"
  public_key = "${file("${var.bootstrap-pub-sshkey-path}")}"
}

resource "aws_instance" "weblogic_app" {
    
    ami = "${var.default_ami}"
    
    instance_type = "t2.micro"
    #count = 2
    subnet_id = "${aws_subnet.app_1.id}"
    key_name = "${aws_key_pair.deployer-keypair.key_name}"

    #user_data = "${file("${path.module}/wls_cloud.init")}"
}


resource "aws_instance" "bastion"{
    
    ami = "${var.default_ami}"
    
    instance_type = "t2.micro"
    #iam_instance_profile = "${aws_iam_instance_profile.read_images_profile.name}"
    subnet_id = "${aws_subnet.public_edge_1.id}"
    key_name = "${aws_key_pair.deployer-keypair.key_name}"

    #user_data = "${file("${path.module}/wls_cloud.init")}"
}