output "bastion_ip" {
    value = "${aws_instance.bastion.public_ip}"
}

output "wls1_ip" {
    value = "${aws_instance.weblogic_app.private_ip}"
}