terraform {
  required_version = ">= 0.12.26"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.45.0, < 4.0.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = ">= 3.1.0, < 4.0.0"
    }
  }
}
