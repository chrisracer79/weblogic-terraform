output "bastion_public_ip" {
    value = "${aws_instance.bastion.public_ip}"
}

output "wls1_private_ip" {
    value = "${aws_instance.weblogic_app.private_ip}"
}

output "database_private_ip" {
    value = "${aws_instance.database.private_ip}"
}