output "public_edge_cidr" {
    value = "${aws_subnet.public_edge.*.cidr_block}"
}

output "app_cidr" {
    value = "${aws_subnet.app.*.cidr_block}"
}

output "data_cidr" {
    value = "${aws_subnet.data.*.cidr_block}"
}

output "bastion_public_ip" {
    value = "${aws_instance.bastion.*.public_ip}"
}

output "app_private_ip" {
    value = "${aws_instance.weblogic_app.*.private_ip}"
}

output "database_private_ip" {
    value = "${aws_instance.database.*.private_ip}"
}