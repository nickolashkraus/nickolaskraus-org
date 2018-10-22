---
title: "Hosting a Static Website with Hugo and AWS"
date: 2018-02-18T12:00:00-06:00
draft: false
description: This article details the steps for creating and hosting a static website on AWS. I provide both the manual steps (via the Amazon Management Console) and the semi-automated steps using AWS CLI.
---

This article details the steps for creating and hosting a static website on AWS. I provide both the manual steps (via the Amazon Management Console) and the semi-automated steps using AWS CLI.

## Hugo
Hugo is a static site generator. The purpose of a static website generator is to render content into HTML files *before* the request for the content is made - increasing performance and reducing load time. To achieve this, Hugo uses a source directory of files and templates as input to create a complete website.

### Getting Started

1. Install Hugo

	```bash
	brew install hugo
	```

2. Create a new site

	```bash
	hugo new site my-site
	```

3. Add source control

	```bash
	cd my-site
	git init
	```

4. Choose a theme

	Pre-made themes can be found [here](https://themes.gohugo.io/). This website uses a custom theme that I created, which can be found [here](https://github.com/NickolasHKraus/black-and-light-2).

	```bash
	git submodule add git@github.com:<username>/<theme>.git themes/<theme>
	```

	Next, copy the `config.toml` from your chosen template into your own.

5. Add content

	```bash
	hugo new posts/my-first-post.md
	```

	**Note**: This will create a new directory, `posts`, and file, `my-first-post.md`, in the `content` directory.

6. Start the Hugo server

	```bash
	hugo server -D
	```

	This will bootstrap your static site. For a more in-depth look at Hugo and how to use it, check out their [documentation](https://gohugo.io/documentation/).

	**Note**: The `-D` option will include content marked as *draft* when running the server or generating static content.

7. Generate static files

	```bash
	hugo
	```

## Amazon Web Services
Amazon Web Services (AWS) is a collection of digital infrastructure services that developers can leverage when developing their applications. The services include computing, storage, database, and application synchronization (messaging and queuing). For this application, we will use:

* Amazon S3
* Amazon CloudFront
* Amazon Route 53

Before diving in, it is advisable to have at least a cursory understanding of the different AWS services we will be using as well as a general idea of the architecture. The following gives an overview of how each Amazon service will be used to achieve our goal.

### Amazon S3
In the most trivial case, to host a static website, you configure an Amazon S3 bucket for website hosting, and then upload your website content to the bucket. The website is then available at the AWS region-specific website endpoint of the bucket. For example:

```
<bucket-name>.s3-website-<AWS-region>.amazonaws.com
```

or

```
<bucket-name>.s3-website.<AWS-region>.amazonaws.com
```

Taking this example further, say you create a bucket called `my-bucket` in the US West (Oregon) Region, and configure it as a website. The following example URLs provide access to your website content:

This URL returns a default index document that you configured for the website.

```
http://my-bucket.s3-website-us-west-2.amazonaws.com/
```

This URL requests the `photo.jpg` object, which is stored at the root level in the bucket.

```
http://my-bucket.s3-website-us-east-1.amazonaws.com/photo.jpg

```

This URL requests the `docs/doc1.html` object in your bucket.

```
http://my-bucket.s3-website-us-east-1.amazonaws.com/docs/doc1.html
```

In addition, you can use your own domain, such as `example.com` to serve your content using Amazon S3 with Amazon Route 53.

### Amazon CloudFront
Amazon CloudFront is a web service that speeds up distribution of your static web content. CloudFront delivers your content through a worldwide network of data centers called edge locations. When a user requests content that you're serving with CloudFront, the user is routed to the edge location that provides the lowest latency (time delay), so that content is delivered with the best possible performance.

### Amazon Route 53
You can use Amazon Route 53 to help you get your website or web application up and running with a custom domain. Route 53 performs three main functions:

1. Domain name registration

2. Routing traffic to the resources for your domain

3. Checking the health of your resources

Amazon Route 53 can be used to fulfill all three functions, however in this case we will only need to register a domain name, then configure Route 53 to route traffic for this domain.

## Setup
The following will provide a painfully detailed walk-through for configuring AWS. I provide both the manual process (via the AWS Management Console) and through the use of the AWS Command Line Interface. It is wise to have the [AWS CLI Command Reference](https://docs.aws.amazon.com/cli/latest/reference/) handy when executing the commands, so you know what everything is doing. When using the AWS CLI, the goal is to replicate the configuration that we obtained using the AWS Management Console.

To simplify the AWS CLI commands, I use environment variables set using a shell script. This script as well as the JSON files used to configure the various AWS services can be found in the GitHub [repository](https://github.com/NickolasHKraus/nickolaskraus-org) for this website under `.aws`.

### Step 0: Prerequisites

1. [Sign up for AWS](https://portal.aws.amazon.com/gp/aws/developer/registration/index.html).

2. Install `awscli`:

```bash
pip install --upgrade awscli
```

**Note**: You will need to configure AWS CLI. To do so, consult the AWS CLI [documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html).

### Step 1: Create S3 buckets

#### Overview

1. Create buckets.

2. Configure buckets.

#### AWS Management Console

1. Go to https://console.aws.amazon.com/s3/.

2. Choose **Create bucket**.

**S3 Bucket for Log Files**

1. Enter a **Bucket name** and **Region**.

	**Example**: `<domain>-logs`

2. Under **Manage system permissions**, select **Grant Amazon S3 Log Delivery group write access to this bucket**.

3. Once the bucket is created, click on the bucket, select **Overview**, then select **Create folder**, and name the folder `cdn/`. This will be the location of log files from Amazon CloudFront.

**S3 Bucket for the Root Domain**

1. Enter a **Bucket name** and **Region**.

	**Example**: `<domain>-logs`

2. Under **Server access logging**, select **Enable logging** then choose the S3 bucket for log files you just created for the **Target bucket** and `cdn/` for the **Target prefix**.

3. Once the bucket is created, click on the bucket, select **Properties**, then **Static website hosting**, then **Use this bucket to host a website**, enter `index.html` and `404.html` for the Index document and Error document respectively. Take note of the endpoint URL - we will use this when configuring the CloudFront distribution.

4. When you configure a bucket as a website, you must make the objects that you want to serve publicly readable. To do this, you write a bucket policy that grants everyone `s3:GetObject` permission. To do this, click on the bucket, select **Permissions**, then **Bucket Policy**, then paste the following:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": [
        "arn:aws:s3:::example-bucket-root/*"
      ]
    }
  ]
}
```

**Note**: Change `example-bucket-root` to the name of your root bucket.

#### AWS CLI

**S3 Bucket for Log Files**

* Create the S3 bucket for log files:

```bash
aws s3 mb s3://$S3_BUCKET_LOGS --region $REGION
```

* Create the `cdn` folder:

```bash
aws s3api put-object --bucket $S3_BUCKET_LOGS --key cdn/
```

* Enable Log Delivery:

```bash
aws s3api put-bucket-acl --bucket $S3_BUCKET_LOGS \
--grant-full-control id=$CANONICAL_USER_ID \
--grant-read 'URI="http://acs.amazonaws.com/groups/s3/LogDelivery"' \
--grant-write 'URI="http://acs.amazonaws.com/groups/s3/LogDelivery"' \
--grant-read-acp 'URI="http://acs.amazonaws.com/groups/s3/LogDelivery"'
```

**Note**: You cannot use an email address to specify a grantee for any AWS Region that was created after 12/8/2014. The following Regions were created after 12/8/2014: US East (Ohio), Canada (Central), Asia Pacific (Mumbai), Asia Pacific (Seoul), EU (Frankfurt), EU (London), EU (Paris), China (Beijing), China (Ningxia), and AWS GovCloud (US). Instead, pass `id` with the canonical user ID to the `--grant-full-control` flag.

**S3 Bucket for the Root Domain**

* Create the S3 bucket for the root domain:

```bash
aws s3 mb s3://$S3_BUCKET_ROOT --region $REGION
```

* Enable logging:

```bash
aws s3api put-bucket-logging --bucket $S3_BUCKET_ROOT --bucket-logging-status file://$S3_LOGGING_POLICY
```

`s3_logging_policy.json`

```json
{
  "LoggingEnabled": {
    "TargetBucket": "example-bucket-logs",
    "TargetPrefix": "cdn/"
  }
}
```

**Note**: Change `example-bucket-logs` to the name of your log bucket.

* Enable static website hosting:

```bash
aws s3api put-bucket-website --bucket $S3_BUCKET_ROOT --website-configuration file://$S3_WEBSITE_CONFIG
```

`s3_website_config.json`

```json
{
  "IndexDocument": {
    "Suffix": "index.html"
  },
  "ErrorDocument": {
    "Key": "404.html"
  }
}
```

* Apply bucket policy:

```bash
aws s3api put-bucket-policy --bucket $S3_BUCKET_ROOT --policy file://$S3_BUCKET_POLICY
```

`s3_bucket_policy.json`

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": [
        "arn:aws:s3:::example-bucket-root/*"
      ]
    }
  ]
}
```

**Note**: Change `example-bucket-root` to the name of your root bucket.

### Step 2: Configure Amazon CloudFront

#### Overview

1. Request a SSL/TLS certificate.

2. Create a CloudFront Distribution.

#### AWS Management Console

**Request a SSL/TLS certificate**

**Warning**: You must be in region `us-east-1` in order to successfully use SSL/TLS certificates. Change your region in the AWS Management Console by selecting **US East (N. Virginia)** from the drop down in the upper right corner.

1. Go to https://console.aws.amazon.com/acm.

2. Click **Get started**.

3. In the **Add domain names** section add the FQDN for your domain name. Click **Add another name to this certificate** and add the www subdomain.

	**Example**:
	```
	example.com
	www.example.com
	```

4. Click **Next**.

5. In the **Select validation method** section, choose **DNS validation**.

6. Click **Review**.

7. Click **Confirm and request**.

8. For each domain, click the carrot, then **Create record in Route 53**. This will automatically create the record used for DNS validation.

#### Create a CloudFront Distribution

1. Go to https://console.aws.amazon.com/cloudfront.

2. Click **Create Distribution**.

3. In the **Select a delivery method for your content** section, choose **Get Started** under **Web**.

4. Fill out the **Create Distribution** form (see below).

5. Click **Create Distribution**

**Origin Settings**

 |
--------|--------|
Origin Domain Name | `example-bucket-root.s3-website.<AWS-region>.amazonaws.com`
Origin Path | `N/A`
Origin ID | `S3-example-bucket-root`
Restrict Bucket Access | `No`
Origin Custom Headers | `N/A`

**Default Cache Behavior Settings**

 |
--------|--------|
Path Pattern | `Default (\*)`
Viewer Protocol Policy | `Redirect HTTP to HTTPS`
Allowed HTTP Methods | `GET, HEAD`
Field-level Encryption Config | `N/A`
Cached HTTP Methods | `GET, HEAD (Cached by default)`
Cache Based on Selected Request Headers | `None (Improves Caching)`
Object Caching | `Use Origin Cache Headers`
Forward Cookies | `None (Improves Caching)`
Query String Forwarding and Caching | `None (Improves Caching)`
Smooth Streaming | `No`
Restrict Viewer Access | `No`
Compress Objects Automatically | `No`
Lambda Function Associations | `N/A`

**Distribution Settings**

 |
--------|--------|
Price Class | `Use All Edge Locations (Best Performance)`
AWS WAF Web ACL | `None`
Alternate Domain Names | `example.com, www.example.com`
SSL Certificate | `Custom SSL Certificate`
Custom SSL Client Support | `Only Clients that Support SNI`
Security Policy | `TLSv1.1_2016 (recommended)`
Supported HTTP Versions | `HTTP/2, HTTP/1.1, HTTP/1.0`
Default Root Object | `index.html`
Logging | `On`
Bucket for Logs | `example-bucket-logs.s3.amazonaws.com`
Log Prefix | `cdn/`
Cookie Logging | `Off`
Enable IPv6 | ☑️
Comment | `N/A`
Distribution State | `Enabled`

**Note**: Select the SSL certificate created for this domain.

**Note**: To get the default `index.html`/`404.html` page functionality, you will need to use the S3 static website URL. If you do not use the S3 static website URL, but instead use the S3 REST endpoint (example-bucket-root.s3.amazonaws.com), you will not get this functionality. CloudFront provides default root object support, such that example.com will return `index.html`, but this will not work for any subdirectories (ex. example.com/blog). The solution is to simply use the S3 static website URL and create a custom origin as opposed to a S3 Origin.

#### AWS CLI

**Request a SSL/TLS certificate**

**Warning**: You must use region `us-east-1` in order to successfully use SSL/TLS certificates. Change your region in the AWS CLI or append the `--region us-east-1` option when requesting a ticket.

* Request a certificate:

```bash
aws acm request-certificate --domain-name $DOMAIN_NAME --validation-method DNS --subject-alternative-names www.$DOMAIN_NAME --idempotency-token 1337
```

**Note**: The returned `CertificateArn` must be used for the following commands

* Use DNS to validate domain ownership:

```bash
aws acm describe-certificate --certificate-arn $CF_CERTIFICATE_ARN
```

**Note**: DNS validation involves creating two CNAME records using the given `Name` and `Value`.

```bash
aws route53 list-hosted-zones-by-name --dns-name $DOMAIN_NAME
```

**Note**: This assumes that you already have a registered domain with Amazon. If you do not, go to **Step 3: Configure Amazon Route 53** and register a domain before creating the records.

```bash
aws route53 change-resource-record-sets --hosted-zone-id $R53_HOSTED_ZONE_ID --change-batch file://$CF_DNS_VALIDATION
```

`cf_dns_validation.json`

```json
{
  "Changes": [
    {
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "",
        "Type": "CNAME",
        "TTL": 300,
        "ResourceRecords": [
          {
            "Value": ""
          }
        ]
      }
    },
    {
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "",
        "Type": "CNAME",
        "TTL": 300,
        "ResourceRecords": [
          {
            "Value": ""
          }
        ]
      }
    }
  ]
}
```

```bash
aws acm list-certificates --certificate-statuses ISSUED
```

**Create a CloudFront Distribution**

* Create a new CloudFront distribution:

```bash
aws cloudfront create-distribution --distribution-config file://$CF_DISTRIBUTION
```

`cf_distribution.json`

```json
{
  "CallerReference": "example.com",
  "Aliases": {
    "Quantity": 2,
    "Items": [
      "www.example.com",
      "example.com"
    ]
  },
  "DefaultRootObject": "index.html",
  "Origins": {
    "Quantity": 1,
    "Items": [
      {
        "Id": "S3-example-root",
        "DomainName": "example-bucket-root.s3-website.<AWS-region>.amazonaws.com",
        "OriginPath": "",
        "CustomHeaders": {
          "Quantity": 0
        },
        "CustomOriginConfig": {
          "HTTPPort": 80,
          "HTTPSPort": 443,
          "OriginProtocolPolicy": "https-only",
          "OriginSslProtocols": {
            "Quantity": 3,
            "Items": [
                "TLSv1",
                "TLSv1.1",
                "TLSv1.2"
            ]
          },
          "OriginReadTimeout": 30,
          "OriginKeepaliveTimeout": 5
        }
      }
    ]
  },
  "DefaultCacheBehavior": {
    "TargetOriginId": "S3-example-root",
    "ForwardedValues": {
      "QueryString": false,
      "Cookies": {
        "Forward": "none"
      }
    },
    "TrustedSigners": {
      "Enabled": false,
      "Quantity": 0
    },
    "ViewerProtocolPolicy": "redirect-to-https",
    "MinTTL": 0,
    "AllowedMethods": {
      "Quantity": 2,
      "Items": [
        "GET",
        "HEAD"
      ],
      "CachedMethods": {
        "Quantity": 2,
        "Items": [
          "GET",
          "HEAD"
        ]
      }
    },
    "SmoothStreaming": false,
    "DefaultTTL": 86400,
    "MaxTTL": 31536000,
    "Compress": true
  },
  "CustomErrorResponses": {
    "Quantity": 1,
    "Items": [
      {
        "ErrorCode": 404,
        "ResponsePagePath": "/404.html",
        "ResponseCode": "404",
        "ErrorCachingMinTTL": 60
      }
    ]
  },
  "Comment": "",
  "Logging": {
    "Enabled": true,
    "IncludeCookies": false,
    "Bucket": "example-logs.s3.amazonaws.com",
    "Prefix": "cdn/"
  },
  "PriceClass": "PriceClass_All",
  "Enabled": true,
  "ViewerCertificate": {
    "ACMCertificateArn": "",
    "SSLSupportMethod": "sni-only",
    "MinimumProtocolVersion": "TLSv1.1_2016",
    "Certificate": "",
    "CertificateSource": "acm"
  },
  "Restrictions": {
    "GeoRestriction": {
      "RestrictionType": "none",
      "Quantity": 0
    }
  },
  "HttpVersion": "http2",
  "IsIPV6Enabled": true
}
```

**Note**: Change `example.com` to the name of your domain, change `example-bucket-root` to the name of your root bucket, and finally, change `ACMCertificateArn` and `Certificate` to the arn of your newly created certificate.

**Note**: To get the default `index.html`/`404.html` page functionality, you will need to use the S3 static website URL. If you do not use the S3 static website URL, but instead use the S3 REST endpoint (example-bucket-root.s3.amazonaws.com), you will not get this functionality. CloudFront provides default root object support, such that example.com will return `index.html`, but this will not work for any subdirectories (ex. example.com/blog). The solution is to simply use the S3 static website URL and create a custom origin as opposed to a S3 Origin.

* Determine the CloudFront domain name:

```bash
aws cloudfront list-distributions --query 'DistributionList.Items[].{Id:Id,DomainName:DomainName,Aliases:Aliases.Items[]}'
```

### Step 3: Configure Amazon Route 53

#### Overview

1. Register a domain name

2. Route traffic to the resources for your domain

#### AWS Management Console

**Register a domain name**

1. Go to https://console.aws.amazon.com/route53.

2. Choose **Registered domains** in the navigation pane, then **Register Domain**.

3. Enter your domain and select a Top-level Domain (TLD), then select **Check**.

4. If the domain is available, select **Add to cart**, then **Continue**.

5. Enter the registrant contact information, then **Continue**.

6. Check the box for *I have read and agree to the AWS Domain Name Registration Agreement*, then **Complete Purchase**.

**Route traffic to the resources for your domain**

1. Go to https://console.aws.amazon.com/route53.

2. Choose **Hosted zones** in the navigation pane.

	**Note**: If you registered your domain with Amazon, a hosted zone will have been automatically created with the name of your domain. A hosted zone contains information about how you want Route 53 to route traffic for the domain.

3. Choose the hosted zone for your domain.

4. Click **Go to Record Sets**.

5. Click **Create Record Set**.

6. Specify the following values (see below).

7. Repeat steps 5 and 6 for your www subdomain.

**Create Record Set**

 |
--------|--------|
Name | -
Type | `A - IPv4 address`
Alias | `Yes`
Alias Target | `CloudFront distribution domain`
Routing Policy | `Simple`
Evaluate Target Health | `No`

#### AWS CLI

* Check your domain's availability:

```bash
aws route53domains check-domain-availability --domain-name $DOMAIN_NAME
```

* Register the domain name:

```bash
aws route53domains register-domain --domain-name $DOMAIN_NAME --duration-in-years $R53_DOMAIN_DURATION --admin-contact file://$R53_CONTACT_INFO --registrant-contact file://$R53_CONTACT_INFO --tech-contact file://$R53_CONTACT_INFO
```

**Note**: The Amazon Route 53 API can only be used in the `us-east-1` region.

`r53_contact_info.json`

```json
{
  "FirstName": "",
  "LastName": "",
  "ContactType": "PERSON",
  "AddressLine1": "",
  "City": "",
  "State": "",
  "CountryCode": "",
  "ZipCode": "",
  "PhoneNumber": "",
  "Email": ""
}
```

**Note**: `State` must be a valid state abbreviation. Ex. NY, CA, OH, etc.

**Note**: `PhoneNumber` must be of the form +999.12345678, where 999 is the country code.

**Configure Route53 to point to point to the new CloudFront distribution**

* Determine the hosted zone for the domain:

```bash
aws route53 list-hosted-zones
```

* Create A records:

```bash
aws route53 change-resource-record-sets --hosted-zone-id $R53_HOSTED_ZONE_ID --change-batch file://$R53_DNS_CONFIG
```

`r53_dns_config.json`

```json
{
  "Changes": [
    {
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "example.com.",
        "Type": "A",
        "AliasTarget": {
          "HostedZoneId": "Z2FDTNDATAQYW2",
          "DNSName": "",
          "EvaluateTargetHealth": false
        }
      }
    },
    {
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "www.example.com.",
        "Type": "A",
        "AliasTarget": {
          "HostedZoneId": "Z2FDTNDATAQYW2",
          "DNSName": "",
          "EvaluateTargetHealth": false
        }
      }
    }
  ]
}
```

**Note**: Change `example.com` to the name of your domain. Change `DNSName` to the domain name of your newly created CloudFront Distribution.

**Note**: The `HostZoneId` must be set to `Z2FDTNDATAQYW2` for CloudFront distributions. Alias resource record sets for CloudFront cannot be created in a private zone.

### Step 4: Deploying your website

#### AWS Management Console

**Upload your website**

1. Go to https://console.aws.amazon.com/s3/.

2. Select **Upload**.

3. Select the contents of `public/` and click **Next**.

4. Under **Manage public permissions**, select **Grant public read access to this object(s)** and click **Next**

5. Under **Storage class**, choose **Standard** and **Encryption** **None** and click **Next**.

6. Click **Upload**.

**Invalidate the CloudFront cache**

1. Go to https://console.aws.amazon.com/cloudfront.

2. Check your distribution and click **Distribution Settings**.

3. Click the **Invalidations** tab, then click **Create Invalidation**.

4. Enter `/*` and click **Invalidate**.

#### AWS CLI

* Upload your website:

```bash
aws s3 sync --acl "public-read" public/ s3://$S3_BUCKET_ROOT
```

* Invalidate the CloudFront cache:

```bash
aws cloudfront create-invalidation --distribution-id $CF_DISTRIBUTION_ID --paths "/*"
```

**Note**: If you specify a path that includes a `*` (wildcard), you must use quotes (") around the path. For example, if you wish to invalidate *all* paths, you would use `"/*"`.

To remove all files or objects in the root bucket, do the following:

```bash
aws s3 rm s3://$S3_BUCKET_ROOT --recursive
```

### FAQ

**Question**:

*Why does my Amazon S3 bucket need to be public?*

**Answer**

In order for your customers to access content at the website endpoint, you must make all your content publicly readable. To do so, you can use a bucket policy or an ACL on an object to grant the necessary permissions.

**Question**:

*Do I need two buckets in order to host my static website on a root and www subdomain?*

**Answer**

The short answer is not necessarily. Most guides that you will come across, including those found in the official Amazon documentation, instruct the user to create an S3 bucket for both the root and wwww subdomain. This is an entirely legitimate solution, however, when using Amazon CloudFront to distribute content, this becomes unnecessary.

**Question**:

*Why am I unable to see the all the AWS resources I created, whether they be through the Amazon Management Console or with the AWS CLI?*

**Answer**

Given that not all services all available in all regions and the region specified in your AWS configuration (`~/.aws/config`) dictates the region from which resources are requested you may not be able to access, or use for that matter, all your resources. I have found that defaulting to `us-east-1` remedied many problems I encountered with creating and using resources generated via the AWS CLI.
