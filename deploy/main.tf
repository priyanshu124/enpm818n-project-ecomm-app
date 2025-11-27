terraform {
  backend "s3" {
    bucket         = "enpm818n-iac-tfstate"
    key            = "enpm818n.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "enpm818n-tf-state-lock"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

locals {
  prefix = "${var.prefix}-${terraform.workspace}"
  common_tags = {
    Environment = terraform.workspace
    Project     = var.project
    Owner       = var.contact
    ManagedBy   = "Terraform"
  }
}
