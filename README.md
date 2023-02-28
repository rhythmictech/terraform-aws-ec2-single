# terraform-aws-ec2-single
Module to create a single EC2 instance.

[![tflint](https://github.com/rhythmictech/terraform-aws-ec2-single/workflows/tflint/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-ec2-single/actions?query=workflow%3Atflint+event%3Apush+branch%3Amaster)
[![tfsec](https://github.com/rhythmictech/terraform-aws-ec2-single/workflows/tfsec/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-ec2-single/actions?query=workflow%3Atfsec+event%3Apush+branch%3Amaster)
[![yamllint](https://github.com/rhythmictech/terraform-aws-ec2-single/workflows/yamllint/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-ec2-single/actions?query=workflow%3Ayamllint+event%3Apush+branch%3Amaster)
[![misspell](https://github.com/rhythmictech/terraform-aws-ec2-single/workflows/misspell/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-ec2-single/actions?query=workflow%3Amisspell+event%3Apush+branch%3Amaster)
[![pre-commit-check](https://github.com/rhythmictech/terraform-aws-ec2-single/workflows/pre-commit-check/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-ec2-single/actions?query=workflow%3Apre-commit-check+event%3Apush+branch%3Amaster)
<a href="https://twitter.com/intent/follow?screen_name=RhythmicTech"><img src="https://img.shields.io/twitter/follow/RhythmicTech?style=social&logo=twitter" alt="follow on Twitter"></a>


## Example
Here's what using the module will look like
```hcl
module "ec2-pet" {
  for_each = local.ec2_pets

  source          = "rhythmictech/ec2-single/aws"
  version         = "1.2.0"
  name            = each.key
  ami_id          = lookup(each.value, "ami_id", data.aws_ami.rce_amzn2.id)
  create_sg       = false
  create_ssm      = false
  env             = "ops"
  instance_type   = each.value.instance_type
  security_groups = concat(try(split(",", each.value.security_groups), []), [module.sg-pet["base"].security_group_id, try(module.sg-pet[each.value.role].security_group_id, null)])
  route53_record  = each.key
  route53_zone_id = data.terraform_remote_state.network.outputs.external_zone_id
  ssm_access_arn  = data.terraform_remote_state.account.outputs.base_instance_arn
  subnet_id       = try(local.private_subnet_ids[each.value.subnet], local.private_subnet_ids[0])
  volume_size     = each.value.volume_size
  volume_type     = each.value.volume_type
  vpc             = data.terraform_remote_state.network.outputs.vpc_id
  tags = merge(
    local.tags,
    {
      "Role"     = each.value.role,
      "Location" = "use1",
      "Env"      = "ops"
    }
  )
}
```


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12.26 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 2.45.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 3.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 2.45.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | >= 3.1.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.instance_tags](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.ssm_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.instance_tags](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ssm_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ssm_access_arn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_key_pair.instance_root](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_route53_record.route53_record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_secretsmanager_secret.instance_root_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.instance_root_key_value](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_security_group.instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [tls_private_key.instance_root](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [aws_iam_policy_document.instance_sts_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.instance_tags](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ssm_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | ID of the AMI to use when creating this instance. | `string` | n/a | yes |
| <a name="input_create"></a> [create](#input\_create) | Whether or not this instance should be created. Unfortunately needed for TF < 0.13. | `bool` | `true` | no |
| <a name="input_create_keypair"></a> [create\_keypair](#input\_create\_keypair) | Whether or not to associate an SSH Keypair with this instance. If this is false and no external\_keypair is defined, no key will be associated with the instance. | `bool` | `false` | no |
| <a name="input_create_sg"></a> [create\_sg](#input\_create\_sg) | Whether or not to create and associate a security group for the instance. | `bool` | `true` | no |
| <a name="input_create_ssm"></a> [create\_ssm](#input\_create\_ssm) | Whether or not to create and associate an IAM managed policy to allow SSM access to the instance. | `bool` | `true` | no |
| <a name="input_ebs_block_device"></a> [ebs\_block\_device](#input\_ebs\_block\_device) | Additional EBS block devices to attach to the instance | `list(map(string))` | `[]` | no |
| <a name="input_env"></a> [env](#input\_env) | Name of the environment the Instance will be in. | `string` | n/a | yes |
| <a name="input_external_keypair"></a> [external\_keypair](#input\_external\_keypair) | Name of an external SSH Keypair to associate with this instance. If create\_keypair is false and this is left null, no keypair will be associated with the instance. | `string` | `null` | no |
| <a name="input_instance_ip"></a> [instance\_ip](#input\_instance\_ip) | Private IP to assign to the instance, if desired. | `string` | `null` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | AWS Instance type, i.e. t3.small. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Moniker to apply to all resources in the module. | `string` | n/a | yes |
| <a name="input_route53_record"></a> [route53\_record](#input\_route53\_record) | Route53 record to point to EC2 instance. | `string` | n/a | yes |
| <a name="input_route53_zone_id"></a> [route53\_zone\_id](#input\_route53\_zone\_id) | Route53 zone ID for the route53\_record. | `string` | n/a | yes |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | Security Group IDs to attach to the instance. | `list(string)` | n/a | yes |
| <a name="input_ssm_access_arn"></a> [ssm\_access\_arn](#input\_ssm\_access\_arn) | Whether or not to associate a pre-created IAM managed policy to allow SSM access to the instance. | `string` | `""` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | ID of the subnet in which to create the instance. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | User-Defined tags. | `map(string)` | `{}` | no |
| <a name="input_userdata_script"></a> [userdata\_script](#input\_userdata\_script) | Userdata script to execute when provisioning the instance. | `string` | `null` | no |
| <a name="input_volume_iops"></a> [volume\_iops](#input\_volume\_iops) | IOPS to allocate to the instance's base drive. Only applicable when volume\_type is io1, io2 or gp3. | `number` | `null` | no |
| <a name="input_volume_size"></a> [volume\_size](#input\_volume\_size) | Size of the attached volume for this instance. | `number` | n/a | yes |
| <a name="input_volume_throughput"></a> [volume\_throughput](#input\_volume\_throughput) | Value in MiB/s for throughput on instance volume. Only applicable when volume\_type is gp3. | `number` | `null` | no |
| <a name="input_volume_type"></a> [volume\_type](#input\_volume\_type) | Type of storage for the instance attached volume. | `string` | n/a | yes |
| <a name="input_vpc"></a> [vpc](#input\_vpc) | VPC ID to create the instance in. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | ARN of the IAM Role generated for this instance |
| <a name="output_iam_role_name"></a> [iam\_role\_name](#output\_iam\_role\_name) | Name of the IAM Role generated for this instance |
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | ID of the instance created |
| <a name="output_instance_sg_id"></a> [instance\_sg\_id](#output\_instance\_sg\_id) | ID of the instance created |
| <a name="output_private_ip"></a> [private\_ip](#output\_private\_ip) | private ip assigned to this instance |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## The Giants Underneath this Module
- [pre-commit.com](pre-commit.com)
- [terraform.io](terraform.io)
- [github.com/tfutils/tfenv](github.com/tfutils/tfenv)
- [github.com/segmentio/terraform-docs](github.com/segmentio/terraform-docs)
