---
title: "Hosting a Static Website with Hugo and CloudFormation"
date: 2019-08-18T00:00:00-06:00
draft: false
description: This article details how to create a static website with Hugo and CloudFormation.
---

In a previous [article](https://nickolaskraus.org/articles/hosting-a-website-with-hugo-and-aws/), I detailed the steps for creating and hosting a static website on AWS. This process can be easily accomplished using CloudFormation, which provides a common language for describing and provisioning infrastructure resources in AWS.

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

## Amazon CloudFormation

### Overview

Hosting a static website on AWS makes use of the following resources:

* Amazon S3
* AWS Certificate Manager
* Amazon CloudFront
* Amazon Route 53

## Prerequisites

First, you must purchase a domain name through Amazon. I plan to automate this process in the future, however, for the time being this can be done through the [AWS Management Console](https://console.aws.amazon.com/route53).

## Creating the CloudFormation template

The CloudFormation template is as follows:

`template.yaml`

```yaml
AWSTemplateFormatVersion: '2010-09-09'

Descriptiocription: Static website for Hugo

Parameters:
  DomainName:
    Description: Domain name of website
    Type: String

Resources:

  S3BucketLogs:
    Type: AWS::S3::Bucket
    DeletionPolicy: Delete
    Properties:
      AccessControl: LogDeliveryWrite
      BucketName: !Sub '${AWS::StackName}-logs'

  S3BucketRoot:
    Type: AWS::S3::Bucket
    DeletionPolicy: Delete
    Properties:
      AccessControl: PublicRead
      BucketName: !Sub '${AWS::StackName}-root'
      LoggingConfiguration:
        DestinationBucketName: !Ref S3BucketLogs
        LogFilePrefix: 'cdn/'
      WebsiteConfiguration:
        ErrorDocument: '404.html'
        IndexDocument: 'index.html'

  S3BucketPolicy:
    Type: AWS::S3::BucketPolicy
    Properties:
      Bucket: !Ref S3BucketRoot
      PolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: 'Allow'
            Action: 's3:GetObject'
            Principal: '*'
            Resource: !Sub '${S3BucketRoot.Arn}/*'

  CertificateManagerCertificate:
    Type: AWS::CertificateManager::Certificate
    Properties:
      DomainName: !Ref DomainName
      ValidationMethod: DNS

  CloudFrontDistribution:
    Type: AWS::CloudFront::Distribution
    Properties:
      DistributionConfig:
        Aliases:
          - !Ref DomainName
        CustomErrorResponses:
          - ErrorCachingMinTTL: 60
            ErrorCode: 404
            ResponseCode: 404
            ResponsePagePath: '/404.html'
        DefaultCacheBehavior:
          AllowedMethods:
            - GET
            - HEAD
          CachedMethods:
            - GET
            - HEAD
          Compress: true
          DefaultTTL: 86400
          ForwardedValues:
            Cookies:
              Forward: none
            QueryString: true
          MaxTTL: 31536000
          SmoothStreaming: false
          TargetOriginId: !Sub 'S3-${AWS::StackName}-root'
          ViewerProtocolPolicy: 'redirect-to-https'
        DefaultRootObject: 'index.html'
        Enabled: true
        HttpVersion: http2
        IPV6Enabled: true
        Logging:
          Bucket: !GetAtt S3BucketLogs.DomainName
          IncludeCookies: false
          Prefix: 'cdn/'
        Origins:
          - CustomOriginConfig:
              HTTPPort: 80
              HTTPSPort: 443
              OriginKeepaliveTimeout: 5
              OriginProtocolPolicy: 'http-only'
              OriginReadTimeout: 30
              OriginSSLProtocols:
                - TLSv1
                - TLSv1.1
                - TLSv1.2
            DomainName: !Sub '${S3BucketRoot}.s3-website.${AWS::Region}.amazonaws.com'
            Id: !Sub 'S3-${AWS::StackName}-root'
        PriceClass: PriceClass_All
        ViewerCertificate:
          AcmCertificateArn: !Ref CertificateManagerCertificate
          MinimumProtocolVersion: TLSv1.1_2016
          SslSupportMethod: sni-only

  Route53RecordSetGroup:
    Type: AWS::Route53::RecordSetGroup
    Properties:
      HostedZoneName: !Sub '${DomainName}.'
      RecordSets:
      - Name: !Ref DomainName
        Type: A
        AliasTarget:
          DNSName: !GetAtt CloudFrontDistribution.DomainName
          EvaluateTargetHealth: false
          HostedZoneId: Z2FDTNDATAQYW2
      - Name: !Sub 'www.${DomainName}'
        Type: A
        AliasTarget:
          DNSName: !GetAtt CloudFrontDistribution.DomainName
          EvaluateTargetHealth: false
          HostedZoneId: Z2FDTNDATAQYW2
: Static website for Hugo

Parameters:
  DomainName:
    Description: Domain name of website
    Type: String

Resources:

  S3BucketLogs:
    Type: AWS::S3::Bucket
    DeletionPolicy: Delete
    Properties:
      AccessControl: LogDeliveryWrite
      BucketName: !Sub '${AWS::StackName}-logs'

  S3BucketRoot:
    Type: AWS::S3::Bucket
    DeletionPolicy: Delete
    Properties:
      AccessControl: PublicRead
      BucketName: !Sub '${AWS::StackName}-root'
      LoggingConfiguration:
        DestinationBucketName: !Ref S3BucketLogs
        LogFilePrefix: 'cdn/'
      WebsiteConfiguration:
        ErrorDocument: '404.html'
        IndexDocument: 'index.html'

  S3BucketPolicy:
    Type: AWS::S3::BucketPolicy
    Properties:
      Bucket: !Ref S3BucketRoot
      PolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: 'Allow'
            Action: 's3:GetObject'
            Principal: '*'
            Resource: !Sub '${S3BucketRoot.Arn}/*'

  CertificateManagerCertificate:
    Type: AWS::CertificateManager::Certificate
    Properties:
      DomainName: !Ref DomainName
      ValidationMethod: DNS

  CloudFrontDistribution:
    Type: AWS::CloudFront::Distribution
    Properties:
      DistributionConfig:
        Aliases:
          - !Ref DomainName
        CustomErrorResponses:
          - ErrorCachingMinTTL: 60
            ErrorCode: 404
            ResponseCode: 404
            ResponsePagePath: '/404.html'
        DefaultCacheBehavior:
          AllowedMethods:
            - GET
            - HEAD
          CachedMethods:
            - GET
            - HEAD
          Compress: true
          DefaultTTL: 86400
          ForwardedValues:
            Cookies:
              Forward: none
            QueryString: true
          MaxTTL: 31536000
          SmoothStreaming: false
          TargetOriginId: !Sub 'S3-${AWS::StackName}-root'
          ViewerProtocolPolicy: 'redirect-to-https'
        DefaultRootObject: 'index.html'
        Enabled: true
        HttpVersion: http2
        IPV6Enabled: true
        Logging:
          Bucket: !GetAtt S3BucketLogs.DomainName
          IncludeCookies: false
          Prefix: 'cdn/'
        Origins:
          - CustomOriginConfig:
              HTTPPort: 80
              HTTPSPort: 443
              OriginKeepaliveTimeout: 5
              OriginProtocolPolicy: 'http-only'
              OriginReadTimeout: 30
              OriginSSLProtocols:
                - TLSv1
                - TLSv1.1
                - TLSv1.2
            DomainName: !Sub '${S3BucketRoot}.s3-website.${AWS::Region}.amazonaws.com'
            Id: !Sub 'S3-${AWS::StackName}-root'
        PriceClass: PriceClass_All
        ViewerCertificate:
          AcmCertificateArn: !Ref CertificateManagerCertificate
          MinimumProtocolVersion: TLSv1.1_2016
          SslSupportMethod: sni-only

  Route53RecordSetGroup:
    Type: AWS::Route53::RecordSetGroup
    Properties:
      HostedZoneName: !Sub '${DomainName}.'
      RecordSets:
      - Name: !Ref DomainName
        Type: A
        AliasTarget:
          DNSName: !GetAtt CloudFrontDistribution.DomainName
          EvaluateTargetHealth: false
          HostedZoneId: Z2FDTNDATAQYW2
      - Name: !Sub 'www.${DomainName}'
        Type: A
        AliasTarget:
          DNSName: !GetAtt CloudFrontDistribution.DomainName
          EvaluateTargetHealth: false
          HostedZoneId: Z2FDTNDATAQYW2
```

To make this CloudFormation template more extensible, I pass in the domain name as a parameter via a `parameters.json` file.

`parameters.json`

```json
[
  {
    "ParameterKey": "DomainName",
    "ParameterValue": "static-website.com"
  }
]
```

## Accessing the default root object from a subfolder or subdirectory

Unfortunately, Amazon CloudFront does not return the default root object (ex. `index.html`) from a subfolder or subdirectory:

> The default root object feature for CloudFront supports only the root of the origin that your distribution points to. CloudFront doesn't return default root objects in subdirectories.

Amazon recommends that you can integrate [Lambda@Edge](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/lambda-at-the-edge.html) with your distribution, however this is cumbersome and unnecessary. Simply create an [Origin](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-cloudfront-distribution-origin.html) using the region-specific website endpoint of the S3 bucket:

```
bucket-name.s3-website-region.amazonaws.com
```

or

```
bucket-name.s3-website.region.amazonaws.com
```

It should be noted that Amazon S3 does not support HTTPS connections when configured as a website endpoint. You must specify **HTTP Only** as the Origin Protocol Policy for your CloudFront distribution:

```yaml
...
Origins:
  - CustomOriginConfig:
      HTTPPort: 80
      HTTPSPort: 443
      OriginKeepaliveTimeout: 5
      OriginProtocolPolicy: 'http-only'
      OriginReadTimeout: 30
      OriginSSLProtocols:
        - TLSv1
        - TLSv1.1
        - TLSv1.2
    DomainName: !Sub '${S3BucketRoot}.s3-website.${AWS::Region}.amazonaws.com'
    Id: !Sub 'S3-${AWS::StackName}-root'
```

## Validating and deploying the CloudFormation stack

```bash
$ aws cloudformation validate-template \
--template-body file://template.yaml
```

```bash
$ aws cloudformation create-stack \
--stack-name <stack-name> \
--template-body file://template.yaml \
--parameters file://parameters.json
```

**Note**: `create-stack` is used in order to pass in parameters as a file. The `deploy` command can be used with the addition of `cat`:

```bash
$ aws cloudformation deploy \
--stack-name <stack-name> \
--template-file template.yaml \
--parameter-overrides $(cat parameters.properties)
```

`parameters.properties`

```properties
DomainName=static-website.com
```

## Validating a certificate with DNS

When you use the `AWS::CertificateManager::Certificate` resource in an AWS CloudFormation stack, the stack will remain in the `CREATE_IN_PROGRESS` state and any further stack operations will be delayed until you validate the certificate request. Certificate validation can be completed either by acting upon the instructions in the certificate validation email or by adding a CNAME record to your DNS configuration.

The **Status Reason** for your CloudFormation deploy will contain the following:

```
Content of DNS Record is: {Name: _x1.static-website.com.,Type: CNAME,Value: _x2.acm-validations.aws.}
```

Where `x1` and `x2` are random hexadecimal strings.

To automate DNS validation, you can use [this](https://github.com/NickolasHKraus/cloudformation-templates/blob/master/static-website-hugo/dns-validation.sh) script.

```bash
./dns-validation.sh $DOMAIN_NAME $STACK_NAME
```

## Automation limitations with DNS validation

Since CloudFormation only outputs the **Name** and **Value** for the validation of the root domain name, any other subdomain that you wish to validate (ex. www), must be manually validated using the **Name** and **Value** given in the [AWS Management Console](https://console.aws.amazon.com/acm).

If you want your website to be accessible via HTTPS on *both* the www subdomain and root domain, you will need to add an alternate name to the certificate and determine the **Name** and **Value** to validate the www subdomain manually:

```yaml
CertificateManagerCertificate:
	Type: AWS::CertificateManager::Certificate
	Properties:
		DomainName: !Ref DomainName
		SubjectAlternativeNames:
			- !Sub www.${DomainName}
		ValidationMethod: DNS
```

You will then be able to add the www subdomain to the CloudFront distribution:

```yaml
CloudFrontDistribution:
	Type: AWS::CloudFront::Distribution
	Properties:
		DistributionConfig:
			Aliases:
				- !Ref DomainName
				- !Sub 'www.${DomainName}'
```

## Testing the static website

First, your static website needs to serve some content.

`hello.md`

```html
---
title: "Hello, World!"
date: 2019-08-18T00:00:00-06:00
draft: false
---

## Hello, World!
```

Upload `public/` to the newly created S3 bucket:

```bash
aws s3 cp --acl "public-read" public/ s3://$S3_BUCKET_ROOT
```

Navigate to your [static website](https://static-website.com/)!

## Conclusion

The code for this CloudFormation stack, as well as other CloudFormation templates can be found at [NickolasHKraus/cloudformation-templates](https://github.com/NickolasHKraus/cloudformation-templates).
