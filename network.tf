locals {
  # Each prefix gets a /24 (based on default VPC CIDR block)
  public_tier_prefix = "${cidrsubnet("${var.vpc_cidr}", 4, 0)}"
  app_tier_prefix = "${cidrsubnet("${var.vpc_cidr}", 4, 1)}"
  data_tier_prefix = "${cidrsubnet("${var.vpc_cidr}", 4, 2)}"
}


resource "aws_subnet" "public_edge" {
    vpc_id = "${aws_vpc.weblogic_vpc.id}"
    count = "${length(var.zones[var.region])}"
    cidr_block = "${cidrsubnet("${local.public_tier_prefix}", 3, count.index)}"
    availability_zone = "${element(var.zones[var.region],count.index)}"
    map_public_ip_on_launch = "true"

    tags {
        Name = "WLS Public Subnet ${count.index}"
    }
}



resource "aws_subnet" "app" {
    vpc_id = "${aws_vpc.weblogic_vpc.id}"
    count = "${length(var.zones[var.region])}"
    cidr_block = "${cidrsubnet("${local.app_tier_prefix}", 3, count.index)}"
    availability_zone = "${element(var.zones[var.region],count.index)}"

    tags {
        Name = "WLS App subnet ${count.index}"
    }
}

resource "aws_subnet" "data" {
    vpc_id = "${aws_vpc.weblogic_vpc.id}"
    count = "${length(var.zones[var.region])}"
    cidr_block = "${cidrsubnet("${local.data_tier_prefix}", 3, count.index)}"
    availability_zone = "${element(var.zones[var.region],count.index)}"

    tags {
        Name = "WLS Data subnet ${count.index}"
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
  subnet_id     = "${aws_subnet.public_edge.*.id[0]}"
  depends_on = ["aws_internet_gateway.igw"]
}

resource "aws_route_table" "public_route" {
  vpc_id = "${aws_vpc.weblogic_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }


  tags {
    Name = "WLS Public route to internet"
  }
}

resource "aws_route_table" "private_route" {
  vpc_id = "${aws_vpc.weblogic_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.ngw.id}"
  }

  tags {
    Name = "WLS Private route to NAT"
  }
}

resource "aws_route_table_association" "public" {
  count = "${length(var.zones)}"
  subnet_id      = "${aws_subnet.public_edge.*.id[count.index]}"
  route_table_id = "${aws_route_table.public_route.id}"
}

resource "aws_route_table_association" "app" {
  count = "${length(var.zones)}"
  subnet_id      = "${aws_subnet.app.*.id[count.index]}"
  route_table_id = "${aws_route_table.private_route.id}"
}

resource "aws_route_table_association" "data" {
  count = "${length(var.zones)}"
  subnet_id      = "${aws_subnet.data.*.id[count.index]}"
  route_table_id = "${aws_route_table.private_route.id}"
}
