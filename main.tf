locals {
  create_ssm  = var.create && var.create_ssm
  create_key  = var.create && var.create_keypair
  create_sg   = var.create && var.create_sg
  instance_sg = try(aws_security_group.instance[0].id, "")
  keypair     = local.create_key ? aws_key_pair.instance_root[0].key_name : var.external_keypair
}

##########################################
# Security Group for instance
##########################################

resource "aws_security_group" "instance" {
  count       = local.create_sg ? 1 : 0
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

data "aws_iam_policy_document" "ssm_access" {

  statement {
    sid       = "ManageWithSSM"
    effect    = "Allow"
    resources = ["*"] #tfsec:ignore:aws-iam-no-policy-wildcards

    actions = [
      "ec2messages:AcknowledgeMessage",
      "ec2messages:DeleteMessage",
      "ec2messages:FailMessage",
      "ec2messages:GetEndpoint",
      "ec2messages:GetMessages",
      "ec2messages:SendReply",
      "ssm:DescribeAssociation",
      "ssm:GetDeployablePatchSnapshotForInstance",
      "ssm:GetDocument",
      "ssm:ListAssociations",
      "ssm:ListInstanceAssociations",
      "ssm:PutInventory",
      "ssm:UpdateAssociationStatus",
      "ssm:UpdateInstanceAssociationStatus",
      "ssm:UpdateInstanceInformation"
    ]
  }

  statement {
    sid       = "SessionManagerAccess"
    effect    = "Allow"
    resources = ["*"] #tfsec:ignore:aws-iam-no-policy-wildcards

    actions = [
      "s3:GetEncryptionConfiguration",
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
  }
}

resource "aws_iam_policy" "ssm_access" {
  count       = local.create_ssm ? 1 : 0
  name_prefix = "${var.name}-ssm-access-"
  policy      = data.aws_iam_policy_document.ssm_access.json
}

resource "aws_iam_role_policy_attachment" "ssm_access" {
  count      = local.create_ssm ? 1 : 0
  role       = aws_iam_role.instance[0].name
  policy_arn = aws_iam_policy.ssm_access[0].arn
}

resource "aws_iam_role_policy_attachment" "ssm_access_arn" {
  count      = var.ssm_access_arn != "" ? 1 : 0
  role       = aws_iam_role.instance[0].name
  policy_arn = var.ssm_access_arn
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

resource "aws_iam_policy" "instance_tags" {
  count       = var.create ? 1 : 0
  name_prefix = "${var.name}-instance-tags-"
  policy      = data.aws_iam_policy_document.instance_tags.json
}

resource "aws_iam_role_policy_attachment" "instance_tags" {
  count      = var.create ? 1 : 0
  role       = aws_iam_role.instance[0].name
  policy_arn = aws_iam_policy.instance_tags[0].arn
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

#tfsec:ignore:aws-ec2-enforce-http-token-imds
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
  vpc_security_group_ids = compact(concat([local.instance_sg], var.security_groups))

  dynamic "ebs_block_device" {
    for_each = var.ebs_block_device
    content {
      delete_on_termination = lookup(ebs_block_device.value, "delete_on_termination", null)
      device_name           = ebs_block_device.value.device_name
      encrypted             = lookup(ebs_block_device.value, "encrypted", null)
      iops                  = lookup(ebs_block_device.value, "iops", null)
      kms_key_id            = lookup(ebs_block_device.value, "kms_key_id", null)
      snapshot_id           = lookup(ebs_block_device.value, "snapshot_id", null)
      volume_size           = lookup(ebs_block_device.value, "volume_size", null)
      volume_type           = lookup(ebs_block_device.value, "volume_type", null)
      throughput            = lookup(ebs_block_device.value, "throughput", null)

      tags = merge(
        var.tags,
        {
          "Name" = var.name
        }
      )
    }
  }

  root_block_device {
    delete_on_termination = true
    encrypted             = true
    iops                  = var.volume_iops
    kms_key_id            = var.volume_kms_key_id
    throughput            = var.volume_throughput
    volume_size           = var.volume_size
    volume_type           = var.volume_type

    tags = merge(
      var.tags,
      {
        "Name" = var.name
      }
    )
  }

  tags = merge(
    var.tags,
    {
      "Name" = var.name
    },
  )

  lifecycle {
    ignore_changes = [
      ebs_block_device,
      ami
    ]
  }
}

##########################################
# Route53 record
##########################################
resource "aws_route53_record" "route53_record" {
  count   = var.route53_record != "" ? 1 : 0
  zone_id = var.route53_zone_id
  name    = var.route53_record
  type    = "A"
  ttl     = "300"
  records = [aws_instance.instance[0].private_ip]
}
