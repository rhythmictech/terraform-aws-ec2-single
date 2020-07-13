output "instance_id" {
  description = "ID of the instance created"
  value       = "${aws_instance.instance.id}"
}

output "instance_sg_id" {
  description = "ID of the instance created"
  value       = "${aws_security_group.instance.id}"
}

output "private_ip" {
  description = "private ip assigned to this instance"
  value       = "${aws_instance.instance.private_ip}"
}

output "iam_role_arn" {
  description = "ARN of the IAM Role generated for this instance"
  value       = aws_iam_role.instance.arn
}
