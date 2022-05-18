##########################################
# Variables
##########################################
variable "ami_id" {
  description = "ID of the AMI to use when creating this instance."
  type        = string
}

variable "create" {
  description = "Whether or not this instance should be created. Unfortunately needed for TF < 0.13."
  type        = bool
  default     = true
}

variable "ebs_block_device" {
  description = "Additional EBS block devices to attach to the instance"
  type        = list(map(string))
  default     = []
}

variable "env" {
  description = "Name of the environment the Instance will be in."
  type        = string
}

variable "external_keypair" {
  default     = null
  description = "Name of an external SSH Keypair to associate with this instance. If create_keypair is false and this is left null, no keypair will be associated with the instance."
  type        = string
}

variable "instance_ip" {
  description = "Private IP to assign to the instance, if desired."
  type        = string
  default     = null
}

variable "instance_type" {
  description = "AWS Instance type, i.e. t3.small."
  type        = string
}

variable "name" {
  description = "Moniker to apply to all resources in the module."
  type        = string
}

variable "security_groups" {
  description = "Security Group IDs to attach to the instance."
  type        = list(string)
}

variable "subnet_id" {
  description = "ID of the subnet in which to create the instance."
  type        = string
}

variable "tags" {
  default     = {}
  description = "User-Defined tags."
  type        = map(string)
}

variable "create_keypair" {
  default     = false
  description = "Whether or not to associate an SSH Keypair with this instance. If this is false and no external_keypair is defined, no key will be associated with the instance."
  type        = bool
}

variable "create_sg" {
  default     = true
  description = "Whether or not to create and associate a security group for the instance. "
  type        = bool
}

variable "create_ssm" {
  default     = true
  description = "Whether or not to create and associate an IAM managed policy to allow SSM access to the instance."
  type        = bool
}

variable "route53_record" {
  description = "Route53 record to point to EC2 instance."
  type        = string
}

variable "route53_zone_id" {
  description = "Route53 zone ID for the route53_record."
  type        = string
}

variable "ssm_access_arn" {
  default     = ""
  description = "Whether or not to associate a pre-created IAM managed policy to allow SSM access to the instance."
  type        = string
}

variable "userdata_script" {
  description = "Userdata script to execute when provisioning the instance."
  type        = string
  default     = null
}

variable "volume_iops" {
  default     = null
  description = "IOPS to allocate to the instance's base drive. Only applicable when volume_type is io1, io2 or gp3."
  type        = number
}

variable "volume_size" {
  description = "Size of the attached volume for this instance."
  type        = number
}

variable "volume_type" {
  description = "Type of storage for the instance attached volume."
  type        = string
}

variable "volume_throughput" {
  default     = null
  description = "Value in MiB/s for throughput on instance volume. Only applicable when volume_type is gp3."
  type        = number
}

variable "vpc" {
  description = "VPC ID to create the instance in."
  type        = string
}
