resource "aws_instance" "weblogic_app" {
    
    count         = 1
    ami           = "${var.default_ami[var.region]}"
    instance_type = "t2.micro"
    subnet_id     = "${aws_subnet.app.*.id[count.index]}"
    key_name      = "${aws_key_pair.deployer-keypair.key_name}"
}


resource "aws_instance" "bastion"{
    count         = 1
    ami           = "${var.default_ami[var.region]}"
    instance_type = "t2.micro"
    subnet_id     = "${aws_subnet.public_edge.*.id[count.index]}"
    key_name      = "${aws_key_pair.deployer-keypair.key_name}"
}

resource "aws_instance" "database"{
    count         = 1
    ami           = "${var.default_ami[var.region]}"
    instance_type = "t2.micro"
    subnet_id     = "${aws_subnet.data.*.id[count.index]}"
    key_name      = "${aws_key_pair.deployer-keypair.key_name}"
}