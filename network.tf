
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