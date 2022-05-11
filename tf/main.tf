# -----------------------------------------------------------------------------
# DEPLOY NICKOLASKRAUS.ORG ON AWS.
# -----------------------------------------------------------------------------
terraform {
  backend "s3" {
    bucket         = "nhk-terraform-state"
    key            = "nickolaskraus-org/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "nhk-terraform-state"
  }
}

provider "aws" {
  region = "us-east-1"
}

module "terraform_aws_static_website" {
  source               = "git@github.com:infrable-io/terraform-aws-static-website.git"
  domain_name          = "nickolaskraus.org"
  redirect_domain_name = "nickolaskraus.io"
}
