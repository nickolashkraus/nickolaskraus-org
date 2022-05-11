---
title: "Migrating NickolasKraus.org to Terraform"
date: 2022-01-03T00:00:00-06:00
draft: false
description: A walk through of the steps taken to migrate NickolasKraus.org to Terraform.
aliases: ["./migrating-nickolaskraus.org-to-terraform"]
---

Back in 2018, I used the AWS CLI and [a collection of JSON files and Bash scripts](https://github.com/NickolasHKraus/nickolaskraus-org/tree/11c438a71905697bdb5fcd172fed95aa3d1cbf8a/.aws) to create the infrastructure for NickolasKraus.org. Since then, I have expanded by repetoire of Infrastructure-as-Code (IaC) tooling to include both CloudFormation and Terraform. With each new tool, I put together an article detailing how to create a static website on AWS. These articles can be found [here](https://nickolaskraus.org/articles/hosting-a-static-website-with-hugo-and-cloudformation/) and [here](https://nickolaskraus.org/articles/hosting-a-static-website-with-hugo-and-terraform/).

Now in 2022, I have decided to put what I've learned into practice by migrating NickolasKraus.org to Terraform. This article provides a walk through of the steps taken to accomplish this task.

## Creating an S3 backend

Terraform is fully capable of storing state on the [local](https://www.terraform.io/language/settings/backends/local) filesystem, however this solution is not fault-tolerant and does not allow easy access to state from multiple hosts. A more durable and flexible solution is to store the state remotely.

This is commonly done using the [S3 backend](https://www.terraform.io/language/settings/backends/s3), which stores the state as a given key in a given bucket on [Amazon S3](https://aws.amazon.com/s3). This backend also supports state locking and consistency checking via [DynamoDB](https://aws.amazon.com/dynamodb), which can be enabled by setting the `dynamodb_table` field to an existing DynamoDB table name.

For my purposes, I chose to create this infrastructure (S3 bucket and DynamoDB table) via CloudFormation, however this needn't be the case. Terraform offers several other options for storing state, Amazon S3 being only one of many.

The repository for creating the S3 bucket and DynamoDB table can be found here:
* [NickolasHKraus/nhk-terraform-state](https://github.com/NickolasHKraus/nhk-terraform-state)

## Importing existing infrastructure into Terraform state

The primary objective of importing infrastructure into Terraform state is to first capture the infrastructure cleanly in Terraform Configuration Language (HCL). This ensures that upon `terraform apply`, the resources remain unchanged:

```
No changes. Your infrastructure matches the configuration.
```

This ensures that the state of the resources captured via code is exactly as configured after inital import. Thereafter, changes to the infrastructure are always accompanied by changes to code, a core tenant of IaC.

### AWS Static Website Terraform Module

To facilitate the process of capturing the infrastructure for NickolasKraus.org as code, I will be using the following public Terraform module:
* [infrable-io/terraform-aws-static-website](https://github.com/infrable-io/terraform-aws-static-website)

Examples for using this Terraform module can be found under [`examples`](https://github.com/infrable-io/terraform-aws-static-website/tree/master/examples). You can also read my accompanying article, [Hosting a Static Website with Hugo and Terraform](https://nickolaskraus.org/articles/hosting-a-static-website-with-hugo-and-terraform/).

### Creating the Terraform module

The Terraform module that uses terraform-aws-static-website is extremely terse:

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

The Terraform backend discussed early is configured and the terraform-aws-static-website is defined.

### Initialize the Terraform working directory

To initialize the Terraform working directory, run the following:

```bash
terraform init
```

This should do the following:
1. Initialize modules (terraform-aws-static-website)
2. Initialize and configure the S3 backend

### Import existing infrastructure

The following AWS resources should be imported:
* ACM Certificate
* CloudFront Distribution
* Route 53 Records
* S3 Buckets

If these resources are not imported, the `terraform apply` will fail.

**NOTE**: Terraform resources have a section on how to import existing infrastructure into your Terraform state. Example: [aws_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket#import).

**ACM Certificate**

  ```bash
  terraform import \
    module.terraform_aws_static_website.aws_acm_certificate.certificate \
    arn:aws:acm:us-east-1:185444048157:certificate/bcf95a60-a87b-4423-b860-6a5924fead18
  ```

**CloudFront Distribution**

  ```bash
  terraform import \
    module.terraform_aws_static_website.aws_cloudfront_distribution.distribution \
    E1QOOVYWY70KUZ
  ```

**Route 53 Records**

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

After each import, the Terraform plan can be generated to ensure no changes would occur:

```
terraform plan -target=resource
```

**NOTE**: Use `-target=resource` to limit the planning operation to only the given module, resource, or resource instance and all of its dependencies.

Unfortunately, given the configuration of the terraform-aws-static-website Terraform module, I needed to create new S3 buckets. However, due to the caching behavior of the CloudFront distribution, switching the origin for the distribution had minimal impact on availability.

When running `terraform plan`, two new buckets are created and the CloudFront distribution is updated in-place.

### Update infrastructure according to Terraform configuration

Finally, I created and updated the infrastructure according to Terraform configuration with the following:

```
terraform apply
```
