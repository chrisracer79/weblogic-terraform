resource "aws_instance" "weblogic_app" {
    
    ami           = "${var.default_ami}"
    instance_type = "t2.micro"
    subnet_id     = "${aws_subnet.app_1.id}"
    key_name      = "${aws_key_pair.deployer-keypair.key_name}"
}


resource "aws_instance" "bastion"{
    
    ami           = "${var.default_ami}"
    instance_type = "t2.micro"
    subnet_id     = "${aws_subnet.public_edge_1.id}"
    key_name      = "${aws_key_pair.deployer-keypair.key_name}"
}

resource "aws_instance" "database"{
    
    ami           = "${var.default_ami}"
    instance_type = "t2.micro"
    subnet_id     = "${aws_subnet.data_1.id}"
    key_name      = "${aws_key_pair.deployer-keypair.key_name}"
}