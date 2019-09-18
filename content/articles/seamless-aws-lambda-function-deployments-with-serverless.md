---
title: "Seamless AWS Lambda function deployments with Serverless"
date: 2019-09-02T12:00:00-06:00
draft: false
description: Serverless enables seamless AWS Lambda deployments.
---

## Problem

With enough use, the shortcomings of AWS CloudFormation start to become apparent. These shortcomings are usually addressed in an inelegant way or by rolling up your sleeves and building your own custom resources.

One such shortcoming is the inability to deploy an AWS Lambda function and the S3 bucket where its deployment package is located in the same CloudFormation template at the same time. Even if the CloudFormation stack is syntactically correct, the deployment will fail when CloudFormation attempts to fetch the Lambda function deployment package from the S3 bucket defined in your CloudFormation stack.

Before diving into a solution, let's revisit the ways in which a Lambda function can be deployed via CloudFormation.

## Deploying an AWS Lambda function via CloudFormation

There are two ways to deploy a Lambda function using CloudFormation:

1. Inline
2. Using Amazon S3

### Inline

For Node.js and Python functions, you can specify the function code inline in the template. This can be accomplished by using the [*literal style*](https://yaml.org/spec/1.2/spec.html#id2795688) block indicator (`|`) and the [`ZipFile`](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-lambda-function-code.html#cfn-lambda-function-code-zipfile) property of the [`AWS::Lambda::Function`](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-lambda-function.html#cfn-lambda-function-code) resource.

### Using Amazon S3

Additionally, you can specify the location of a deployment package in Amazon S3 by providing an S3 bucket ([`S3Bucket`](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-lambda-function-code.html#cfn-lambda-function-code-s3bucket)) and S3 key ([`S3Key`](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-lambda-function-code.html#cfn-lambda-function-code-s3key)).

This is where a Lambda deployment can become cumbersome, as it is impossible to define a Lambda function resource *and* the S3 bucket from which the Lambda function deployment package is retrieved in the same CloudFormation template.

## Solutions

Given this limitation, various solutions arise.

### The Wrong Way

In order to deploy both a Lambda function and the S3 bucket in which it reside, you must first deploy the CloudFormation stack with the S3 bucket, put the Lambda function deployment package in the S3 bucket, then specify the S3 bucket and object key in the CloudFormation template for the Lambda function resource before deploying the template again.

This solution has the following workflow.

1. Create an AWS Lambda function using [`Zipfile`](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-lambda-function-code.html#cfn-lambda-function-code-zipfile) and the deployment S3 bucket:

```bash
LambdaFunction:
  Type: AWS::Lambda::Function
  Properties:
    Code:
      # S3Bucket: !Ref LambdaS3Bucket
      # S3Key: 'lambda_function.zip'
      # Use ZipFile to address 'chicken and egg' problem
      ZipFile: |
        def handler(event, context):
          return

LambdaS3Bucket:
  Type: AWS::S3::Bucket
  Properties:
    AccessControl: AuthenticatedRead
    BucketName: '${AWS::StackName}-lambda'
    VersioningConfiguration:
      Status: Enabled
```

**Note**: The deployment S3 bucket is commented out for the first deployment.

2. Deploy the CloudFormation stack:

```bash
aws cloudformation deploy \
--stack-name $STACK_NAME \
--template-file template.yaml \
--parameter-overrides $(cat parameters.properties)
```

3. Deploy the AWS Lambda function to the deployment S3 bucket:

```bash
aws s3api put-object \
--body lambda_function.zip \
--bucket $STACK_NAME-lambda \
--key lambda_function.zip
```

4. Uncomment the deployment S3 bucket ([`S3Bucket`](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-lambda-function-code.html#cfn-lambda-function-code-s3bucket)) in the Lambda function, comment out the `Zipfile`:

```bash
LambdaFunction:
  Type: AWS::Lambda::Function
  Properties:
    Code:
      S3Bucket: !Ref LambdaS3Bucket
      S3Key: 'lambda_function.zip'
      # Use ZipFile to address 'chicken and egg' problem
      # ZipFile: |
      #   def handler(event, context):
      #     return
```

5. Redeploy the CloudFormation stack.

### The Right Way

Just use [Serverless](https://serverless.com)!

## Serverless

This is where Serverless Framework comes in.

Serverless uses the same methodology, but in a seamless, deterministic way. There is no need to execute two initial deploys, Serverless handles this maladroit process transparently for the user.

1. First, Serverless creates a CloudFormation template with only the deployment S3 bucket and deploys the CloudFormation stack:

```bash
Serverless: Packaging service...
Serverless: Excluding development dependencies...
Serverless: Creating Stack...
Serverless: Checking Stack create progress...
...
Serverless: Stack create finished...
```

2. Serverless then packages the AWS Lambda function and uploads the deployment package to S3:

```bash
Serverless: Uploading CloudFormation file to S3...
Serverless: Uploading artifacts...
...
```

3. Any IAM Roles, Functions, Events and Resources are added to the AWS CloudFormation template and the CloudFormation stack is updated:

```bash
Serverless: Validating template...
Serverless: Updating Stack...
Serverless: Checking Stack update progress...
...
Serverless: Stack update finished...
```

Voilà! Painless AWS Lambda function deploys!

## Conclusion

Amazon has enabled entire companies to be created around specific shortcomings in their platform. [Serverless](https://serverless.com/), a framework that facilitates seamless deployments of AWS Lambda functions, addresses the chicken and egg problem when deploying a CloudFormation stack that defines an AWS Lambda function *and* the S3 bucket in which it resides.

As software development moves toward more *serverless* technology (architectures leveraging AWS Lambda, Azure Functions, Google Cloud Functions, etc.), the need to development robust continuous deployment pipelines becomes more important. In the case of AWS Lambda, Serverless provides a simple solution to a common problem and we plan to continue to use their service as we grow our serverless infrastructure.
