---
title: "Hosting a Static Website with Hugo and Terraform"
date: 2021-12-27T00:00:00-06:00
draft: false
description: This article details how to create a static website with Hugo and Terraform.
---

In 2018, I created an [article](https://nickolaskraus.org/articles/hosting-a-static-website-with-hugo-and-aws/) on how to create a static website on AWS.

In 2019, I created an [article](https://nickolaskraus.org/articles/hosting-a-static-website-with-hugo-and-cloudformation/) on how to create a static website on AWS using CloudFormation.

Now, in the final days of 2021, the final chapter has been written: how to create a static website on AWS using Terraform.

## Hugo

[Hugo](https://gohugo.io/) is a static site generator. The purpose of a static website generator is to render content into HTML files *before* the request for the content is made - increasing performance and reducing load time. To achieve this, Hugo uses a source directory of files and templates as input to create a complete website.

To get started with Hugo, refer to their [Getting Started](https://gohugo.io/getting-started/) documentation.

## Terraform

### Overview

Hosting a static website on AWS requires the following resources:
* Amazon S3
* AWS Certificate Manager
* Amazon CloudFront
* Amazon Route 53

### Prerequisites

First, you must purchase a domain name through Amazon. This can be done through the [AWS Management Console](https://console.aws.amazon.com/route53).

### Creating the Terraform module

This article uses a public Terraform module maintained by Infrable.io:
* [infrable-io/terraform-aws-static-website](https://github.com/infrable-io/terraform-aws-static-website)

To use this module the following files are required:
* `main.tf`
* `outputs.tf`

An example Terraform module can be found [here](https://github.com/NickolasHKraus/static-website-com).

### Deploying the Terraform module

Initialize the Terraform module:

```bash
terraform init
```

To see the speculative execution plan, run:

```bash
terraform plan
```

If you are satisfied with the output, create the infrastructure:

```bash
terraform apply
```

## Publishing content

This can be accomplished with a simple script. See `publish` in [NickolasHKraus/static-website-com](https://github.com/NickolasHKraus/static-website-com).

The exact steps provided in this article were used to deploy [static-website.com](https://static-website.com/)!

## Conclusion

You might haved noticed that the process for creating a static website on AWS using Terraform is far less cumbersome. This is due to the ease of creating and sharing Terraform modules.
