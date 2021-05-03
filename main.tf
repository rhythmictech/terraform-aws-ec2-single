locals {
  allow_ssm  = var.create && var.use_ssm
  create_key = var.create && var.create_keypair
  keypair    = local.create_key ? aws_key_pair.instance_root[0].key_name : var.external_keypair
}

##########################################
# Security Group for instance
##########################################

resource "aws_security_group" "instance" {
  count       = var.create ? 1 : 0
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

##########################################
# Instance IAM role and initial policy setup
##########################################

data "aws_iam_policy_document" "instance_sts_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy" "ssm_access" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role" "instance" {
  count              = var.create ? 1 : 0
  name_prefix        = "${substr(var.name, 0, 26)}-role-"
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
  count       = var.create ? 1 : 0
  name_prefix = "${var.name}-"
  role        = aws_iam_role.instance[0].id
  policy      = data.aws_iam_policy_document.instance_tags.json
}

resource "aws_iam_instance_profile" "instance" {
  count       = var.create ? 1 : 0
  name_prefix = "${var.name}-"
  role        = aws_iam_role.instance[0].name
}

resource "aws_iam_role_policy_attachment" "ssm_access" {
  count      = local.allow_ssm ? 1 : 0
  role       = aws_iam_role.instance[0].name
  policy_arn = data.aws_iam_policy.ssm_access.arn
}

##########################################
# Instance root key creation/storage
##########################################

resource "tls_private_key" "instance_root" {
  count     = local.create_key ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "instance_root" {
  count           = local.create_key ? 1 : 0
  key_name_prefix = "${var.name}-root-"
  public_key      = tls_private_key.instance_root[0].public_key_openssh
}

resource "aws_secretsmanager_secret" "instance_root_key" {
  count       = local.create_key ? 1 : 0
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
  count         = local.create_key ? 1 : 0
  secret_id     = aws_secretsmanager_secret.instance_root_key[0].id
  secret_string = tls_private_key.instance_root[0].private_key_pem
}
##########################################
# Instance Definition
##########################################
resource "aws_instance" "instance" {
  count                  = var.create ? 1 : 0
  ami                    = var.ami_id
  iam_instance_profile   = aws_iam_instance_profile.instance[0].id
  instance_type          = var.instance_type
  key_name               = local.keypair
  monitoring             = true
  private_ip             = var.instance_ip != null ? var.instance_ip : null
  subnet_id              = var.subnet_id
  user_data              = var.userdata_script
  vpc_security_group_ids = concat([aws_security_group.instance[0].id], var.security_groups)

  root_block_device {
    delete_on_termination = true
    volume_size           = var.volume_size
    volume_type           = var.volume_type
  }

  tags = merge(
    var.tags,
    {
      "Name" = var.name
    },
  )
}
