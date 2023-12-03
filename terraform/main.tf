terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket = "resume-challenge-terraform"
    key = "terraform.tfstate"
    region = "eu-west-1"
    dynamodb_table = "resume-challenge-tf-state"
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-west-1"
}


# Retrieve the AWS account number
# To Avoid hardcode it
data "aws_caller_identity" "current" {}

locals {
  aws_account_number = data.aws_caller_identity.current.account_id
}

