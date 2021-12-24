---
title: "Migrating NickolasKraus.org to Terraform"
date: 2022-01-03T00:00:00-06:00
draft: false
description: A walk through of the steps taken to migrate NickolasKraus.org to Terraform.
---

Back in 2018, I used the AWS CLI and [a collection of JSON files and Bash scripts]() to create the infrastructure for NickolasKraus.org. Since then, I have expanded by repetoire of Infrastructure-as-Code (IaC) tooling to include both CloudFormation and Terraform. With each new tool, I put together an article detailing how to create a static website on AWS. These articles can be found [here]() and [here]().

Now in 2022, I decided to put into practice what I've learned in the past few years by migrating NickolasKraus.org to Terraform. This article provides a walk through of the steps taken to accomplish this task.

## Creating an S3 backend

Terraform is fully capable of storing state on the local filesystem, however this solution is not fault-tolerant and does not allow easy access to state from multiple hosts. A more durable and flexible solution is to store the state remotely.

This is commonly done using the S3 backend, which stores the state as a given key in a given bucket on [Amazon S3](https://aws.amazon.com/s3). This backend also supports state locking and consistency checking via [DynamoDB](https://aws.amazon.com/dynamodb), which can be enabled by setting the `dynamodb_table` field to an existing DynamoDB table name.

For my purposes, I chose to create this infrastructure (S3 bucket and DynamoDB table) via CloudFormation, however this needn't be the case. Terraform offers several options for storing state, Amazon S3 being only one of many.

The repository for creating the S3 bucket and DynamoDB table can be found here:
* [NickolasHKraus/nhk-terraform-state](https://github.com/NickolasHKraus/nhk-terraform-state)

## Importing existing infrastructure into Terraform state

The primary goal of importing infrastructure into Terraform state is to first capture the infrastructure cleanly in Terraform Configuration Language (HCL). This ensures that upon `terraform apply`, the resources remain unchanged:

```
No changes. Your infrastructure matches the configuration.
```

This ensures that the state of resources captured via code after inital import is exactly as configured. Thereafter, changes to the infrastructure are always accompanied by changes to code, a core tenany of IaC.

### AWS Static Website Terraform Module

Early 2020 was a restless time for me and I thought about starting a company to leverage my knowledge of Cloud technologies. Infrable.io was concieved on a brisk winter morning in late December. Though this enterprise never took off, it does count to its intellectual property a Terraform module for hosting a static website on AWS:
* [infrable-io/terraform-aws-static-website](https://github.com/infrable-io/terraform-aws-static-website)

Examples for using this Terraform module can be found under `examples/`. You can read my accompanying article, [Hosting a Static Website with Hugo and Terraform]().

### Creating the Terraform module

The Terraform module that imports terraform-aws-static-website is extremely terse:

`main.tf`

```hcl
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
  source      = "git@github.com:infrable-io/terraform-aws-static-website.git"
  domain_name = "nickolaskraus.org"
}
```

`outputs.tf`

```hcl
output "s3_root_id" {
  value       = module.terraform_aws_static_website.s3_root_id
  description = "The name of the root S3 bucket"
}

output "cf_distribution_id" {
  value       = module.terraform_aws_static_website.cf_distribution_id
  description = "The identifier for the CloudFront distribution"
}
```

The Terraform backend discussed early is configured and the terraform-aws-static-website is imported.

### Initialize

```bash
terraform init
```

Initializing the Terraform directory should have the following effect:
1. Initializes modules (terraform-aws-static-website)
2. Configures S3 backend

## Import

It should be noted that all Terraform resources have a section on how to import existing infrastructure into your Terraform state
* Amazon S3
* AWS Certificate Manager
* Amazon CloudFront
* Amazon Route 53

ACM Certificate

```bash
terraform import \
  module.terraform_aws_static_website.aws_acm_certificate.certificate \
  arn:aws:acm:us-east-1:185444048157:certificate/bcf95a60-a87b-4423-b860-6a5924fead18
```

Amazon CloudFront Distribution

```bash
terraform import \
  module.terraform_aws_static_website.aws_cloudfront_distribution.distribution \
  E1QOOVYWY70KUZ
```

Amazon S3

```bash
terraform import \
  module.terraform_aws_static_website.aws_s3_bucket.s3_logs \
  nickolaskraus-logs
```

```bash
terraform import \
  module.terraform_aws_static_website.aws_s3_bucket.s3_root \
  nickolaskraus-root
```

```bash
terraform import \
  module.terraform_aws_static_website.aws_route53_record.dns_record_root \
  Z3OMX3SLNACZXW_nickolaskraus.org_A
```

```bash
terraform import \
  module.terraform_aws_static_website.aws_route53_record.dns_record_www \
  Z3OMX3SLNACZXW_www.nickolaskraus.org_A
```

After each import, I tested the Terraform plan to ensure no changes would occur

tf plan -target <resource>


Unfortunately, given the configuration of the Terraform module, I needed to create new S3 buckets. Had this been a production application with millions of users, I different rollout strategy would have been undertaken. However, since this is my site and I do not have a SLA guarenting six nines of uptime, the momentary downtime was fine.

When running Terraform plan, we see that two new buckets are created and the CloudFront distribution is updated in-place.
