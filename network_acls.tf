
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
  subnet_ids = ["${aws_subnet.public_edge.*.id}"]

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
  subnet_ids = ["${aws_subnet.app.*.id}"]

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
  subnet_ids = ["${aws_subnet.data.*.id}"]

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