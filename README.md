# terraform-terraform-template
Template repository for terraform modules. Good for any cloud and any provider.

[![tflint](https://github.com/rhythmictech/terraform-terraform-template/workflows/tflint/badge.svg?branch=main&event=push)](https://github.com/rhythmictech/terraform-terraform-template/actions?query=workflow%3Atflint+event%3Apush+branch%3Amain)
[![tfsec](https://github.com/rhythmictech/terraform-terraform-template/workflows/tfsec/badge.svg?branch=main&event=push)](https://github.com/rhythmictech/terraform-terraform-template/actions?query=workflow%3Atfsec+event%3Apush+branch%3Amain)
[![yamllint](https://github.com/rhythmictech/terraform-terraform-template/workflows/yamllint/badge.svg?branch=main&event=push)](https://github.com/rhythmictech/terraform-terraform-template/actions?query=workflow%3Ayamllint+event%3Apush+branch%3Amain)
[![misspell](https://github.com/rhythmictech/terraform-terraform-template/workflows/misspell/badge.svg?branch=main&event=push)](https://github.com/rhythmictech/terraform-terraform-template/actions?query=workflow%3Amisspell+event%3Apush+branch%3Amain)
[![pre-commit-check](https://github.com/rhythmictech/terraform-terraform-template/workflows/pre-commit-check/badge.svg?branch=main&event=push)](https://github.com/rhythmictech/terraform-terraform-template/actions?query=workflow%3Apre-commit-check+event%3Apush+branch%3Amain)
<a href="https://twitter.com/intent/follow?screen_name=RhythmicTech"><img src="https://img.shields.io/twitter/follow/RhythmicTech?style=social&logo=twitter" alt="follow on Twitter"></a>

## Example
Here's what using the module will look like
```hcl
module "example" {
  source = "rhythmictech/terraform-mycloud-mymodule
}
```

## About
A bit about this module

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.14 |

## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| tls | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ami\_id | ID of the AMI to use when creating this instance. | `string` | n/a | yes |
| env | Name of the environment the Instance will be in. | `string` | n/a | yes |
| instance\_type | AWS Instance type, i.e. t3.small. | `string` | n/a | yes |
| name | Moniker to apply to all resources in the module. | `string` | n/a | yes |
| security\_groups | Security Group IDs to attach to the instance. | `list(string)` | n/a | yes |
| subnet\_id | ID of the subnet in which to create the instance. | `string` | n/a | yes |
| volume\_size | Size of the attached volume for this instance. | `number` | n/a | yes |
| volume\_type | Type of storage for the instance attached volume. | `string` | n/a | yes |
| vpc | VPC ID to create the instance in. | `string` | n/a | yes |
| create | Whether or not this instance should be created. Unfortunately needed for TF < 0.13. | `bool` | `true` | no |
| instance\_ip | Private IP to assign to the instance, if desired. | `string` | `null` | no |
| tags | User-Defined tags. | `map(string)` | `{}` | no |
| userdata\_script | Userdata script to execute when provisioning the instance. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| iam\_role\_arn | ARN of the IAM Role generated for this instance |
| instance\_id | ID of the instance created |
| instance\_sg\_id | ID of the instance created |
| private\_ip | private ip assigned to this instance |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## The Giants Underneath this Module
- [pre-commit.com](pre-commit.com)
- [terraform.io](terraform.io)
- [github.com/tfutils/tfenv](github.com/tfutils/tfenv)
- [github.com/segmentio/terraform-docs](github.com/segmentio/terraform-docs)
