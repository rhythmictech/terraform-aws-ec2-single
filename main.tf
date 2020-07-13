########################################
# Security Group for instance
########################################

resource "aws_security_group" "instance" {
  name_prefix = "${var.env}-${var.name}-"
  description = "Security group attached to the ${var.env}-${var.name} instance."
  vpc_id      = var.vpc

  tags = merge(
    var.tags,
    {
      "Name" = "${var.env}-${var.name}"
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

########################################
# Instance IAM role and initial policy setup
########################################

data "aws_iam_policy_document" "instance_sts_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "instance" {
  name_prefix        = "${var.name}-role-"
  assume_role_policy = data.aws_iam_policy_document.instance_sts_assume_role.json

  tags = merge(
    var.tags,
    {
      "Name" = "${var.name}-role"
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_iam_policy_document" "instance_tags" {
  statement {
    actions = [
      "ec2:DescribeTags",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_role_policy" "instance" {
  name_prefix = "${var.name}-"
  role        = aws_iam_role.instance.id
  policy      = data.aws_iam_policy_document.instance_tags.json
}

resource "aws_iam_instance_profile" "instance" {

  name_prefix = "${var.name}-"
  role        = aws_iam_role.instance.name
}

########################################
# Instance root key creation/storage
########################################

resource "tls_private_key" "instance_root" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "instance_root" {
  key_name_prefix = "${var.name}-root-"
  public_key      = tls_private_key.instance_root.public_key_openssh
}

resource "aws_secretsmanager_secret" "instance_root_key" {
  name_prefix = "${var.name}-root-key-"
  description = "ssh key for ec2-user user on ${var.name} server"

  tags = merge(
    var.tags,
    {
      "Name" = "${var.name}-key"
    },
  )
}

resource "aws_secretsmanager_secret_version" "instance_root_key_value" {
  secret_id     = aws_secretsmanager_secret.instance_root_key.id
  secret_string = tls_private_key.instance_root.private_key_pem
}
########################################
# Instance Definition
########################################
resource "aws_instance" "instance" {
  ami                    = var.ami_id
  iam_instance_profile   = aws_iam_instance_profile.instance.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.instance_root.key_name
  monitoring             = true
  private_ip             = var.instance_ip != null ? var.instance_ip : null
  subnet_id              = var.subnet_id
  user_data              = var.userdata_script
  vpc_security_group_ids = concat([aws_security_group.instance.id], var.security_groups)

  root_block_device {
    delete_on_termination = true
    volume_size           = var.volume_size
    volume_type           = var.volume_type
  }

  tags = merge(
    var.tags,
    {
      "Name" = "${var.name}"
    },
  )
}
