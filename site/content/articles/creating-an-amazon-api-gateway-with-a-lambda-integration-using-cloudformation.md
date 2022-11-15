---
title: "Creating an Amazon API Gateway with a Lambda Integration using CloudFormation"
date: 2019-02-03T00:00:00-06:00
draft: false
description: A typical use case for Amazon API Gateway is to use it in conjunction with an AWS Lambda function. In this article, we will create an API Gateway with a Lambda integration.
---

In my last article, I discussed how to set up an API Gateway with a mock integration using CloudFormation. With an understanding of the fundamentals of API Gateway, we can now leverage it to do something useful. In this article, we will use Amazon API Gateway to invoke a simple Lambda function.

## Overview
This use case is common enough to warrant its own name: *Amazon API Gateway Lambda proxy integration*. A Lambda proxy integration is a simple, powerful, and nimble mechanism for providing robust request handling for a single API method. The Lambda proxy integration allows the client to call a single Lambda function on the backend. The Lambda function can then access any resources or features of other AWS services to complete its objective, which can include calling other Lambda functions.

With a Lambda proxy integration, when a client submits an API request, API Gateway passes the raw request to the integrated Lambda function as-is. Appended to the request data are request headers, query string parameters, URL path variables, payload, and API configuration data. This allows the Lambda function to access the context of the API request. The configuration data can include current deployment stage name, stage variables, user identity, or authorization context (if any). The backend Lambda function parses the incoming request data to determine the response that it returns. For API Gateway to pass the Lambda output as an API response to the client, the Lambda function must return the result in a specific format (see [Output Format of a Lambda Function for Proxy Integration]({{< ref "#Output Format of a Lambda Function for Proxy Integration" >}})).

Because API Gateway doesn't intervene very much between the client and the backend Lambda function for the Lambda proxy integration, the client and the integrated Lambda function can adapt to changes in each other without breaking the existing integration setup of the API. To enable this, the client must follow application protocols enacted by the backend Lambda function.

You can set up a Lambda proxy integration for any API method. But a Lambda proxy integration is more potent when it is configured for an API method involving a generic proxy resource. The generic proxy resource can be denoted by a special templated path variable of `{proxy+}`, the catch-all `ANY` method placeholder, or both. The client can pass the input to the backend Lambda function in the incoming request as request parameters or applicable payload. The request parameters include headers, URL path variables, query string parameters, and the applicable payload. The integrated Lambda function verifies all of the input sources before processing the request and responding to the client with meaningful error messages if any of the required input is missing.

In this way, the business logic of the exposed API endpoint is comprised entirely within the Lambda function, which is wholly responsible for handling and responsing to the request. This method is applicable when you wish to use an API Gateway as a pure proxy, with little to no intervention on the incoming request.

## Proxy integration vs. Custom integration
You can integrate an API method with a Lambda function using a Lambda *proxy integration* or a Lambda *custom integration*.

### Proxy integration
With a *proxy integration*, the setup is simple. If your API does not require content encoding or caching, you only need to do the following:

1. Set the integration's HTTP method to POST.
2. Set the integration endpoint URI to the ARN of the Lambda function invocation action of a specific Lambda function.
3. Set the credential to an IAM role with permissions to allow API Gateway to call the Lambda function on your behalf.

### Custom integration
With a *custom integration*, the setup is more involved. In addition to the proxy integration setup steps, you also specify how the incoming request data is mapped to the integration request and how the resulting integration response data is mapped to the method response.

### Input Format of a Lambda Function for Proxy Integration
With a Lambda proxy integration, API Gateway maps the entire client request to the input event parameter of the backend Lambda function as follows:

```json
{
  "resource": "Resource path",
  "path": "Path parameter",
  "httpMethod": "Incoming request's method name"
  "headers": {String containing incoming request headers}
  "multiValueHeaders": {List of strings containing incoming request headers}
  "queryStringParameters": {query string parameters }
  "multiValueQueryStringParameters": {List of query string parameters}
  "pathParameters":  {path parameters}
  "stageVariables": {Applicable stage variables}
  "requestContext": {Request context, including authorizer-returned key-value pairs}
  "body": "A JSON string of the request payload."
  "isBase64Encoded": "A boolean flag to indicate if the applicable request payload is Base64-encode"
}
```

### Output Format of a Lambda Function for Proxy Integration {#Output Format of a Lambda Function for Proxy Integration}
With a Lambda proxy integration, API Gateway requires the backend Lambda function to return output according to the following JSON format:

```json
{
  "isBase64Encoded": true|false,
  "statusCode": httpStatusCode,
  "headers": { "headerName": "headerValue", ... },
  "multiValueHeaders": { "headerName": ["headerValue", "headerValue2", ...], ... },
  "body": "..."
}
```

## Why use an AWS Lambda function?
You may be wondering why a simple AWS integration would not suffice. If you recall, an AWS integration lets an API expose AWS service actions. So why are we using an AWS Lambda function to proxy the request? The reason for doing so is twofold:

1. An AWS Lambda function allows for more robust handling of requests.
2. API Gateway simply does not work with some AWS services.

In my particle application, the AWS integration simply could not successfully invoke the API of the backend AWS service. In addition, the ability to apply more complex business logic to a client request is a very attractive feature when building a complex system.

## Creating the CloudFormation template
The following sections provide information on each resource that is used to create a Lambda proxy integration.

### Step 1: Create a ApiGateway::RestApi resource

`AWS::ApiGateway::RestApi` has the following form:

```yaml
ApiGatewayRestApi:
  Type: AWS::ApiGateway::RestApi
  Properties:
    ApiKeySourceType: HEADER
    Description: An API Gateway with a Lambda Integration
    EndpointConfiguration:
      Types:
        - EDGE
    Name: lambda-api
```

### Step 2: Create a ApiGateway::Resource resource

`AWS::ApiGateway::Resource` has the following form:

```yaml
ApiGatewayResource:
  Type: AWS::ApiGateway::Resource
  Properties:
    ParentId: !GetAtt ApiGatewayRestApi.RootResourceId
    PathPart: 'lambda'
    RestApiId: !Ref ApiGatewayRestApi
```

### Step 3: Create a AWS::ApiGateway::Method resource

`AWS::ApiGateway::Method` has the following form:

```yaml
ApiGatewayMethod:
  Type: AWS::ApiGateway::Method
  Properties:
    ApiKeyRequired: false
    AuthorizationType: NONE
    HttpMethod: POST
    Integration:
      ConnectionType: INTERNET
      Credentials: !GetAtt ApiGatewayIamRole.Arn
      IntegrationHttpMethod: POST
      PassthroughBehavior: WHEN_NO_MATCH
      TimeoutInMillis: 29000
      Type: AWS_PROXY
      Uri: !Sub 'arn:aws:apigateway:${AWS::Region}:lambda:path/2015-03-31/functions/${LambdaFunction.Arn}/invocations'
    OperationName: 'lambda'
    ResourceId: !Ref ApiGatewayResource
    RestApiId: !Ref ApiGatewayRestApi
```

**Note**: You can may notice that this `Method` is rather simple. It does not have `IntegrationResponses`, `RequestTemplates`, or `MethodResponses` properties. This is because this `Method` is purely proxying the client request and Lambda function response. Therefore, there is no need to define models or templates for these entities.

### Step 4: Create a AWS::ApiGateway::Model resource

`AWS::ApiGateway::Model` has the following form:

```yaml
ApiGatewayModel:
  Type: AWS::ApiGateway::Model
  Properties:
    ContentType: 'application/json'
    RestApiId: !Ref ApiGatewayRestApi
    Schema: {}
```

### Step 5: Create a AWS::ApiGateway::Stage resource

`AWS::ApiGateway::Stage` has the following form:

```yaml
ApiGatewayStage:
  Type: AWS::ApiGateway::Stage
  Properties:
    DeploymentId: !Ref ApiGatewayDeployment
    Description: Lambda API Stage v0
    RestApiId: !Ref ApiGatewayRestApi
    StageName: 'v0'
```

### Step 6: Create a AWS::ApiGateway::Deployment resource

`AWS::ApiGateway::Deployment` has the following form:

```yaml
ApiGatewayDeployment:
  Type: AWS::ApiGateway::Deployment
  DependsOn: ApiGatewayMethod
  Properties:
    Description: Lambda API Deployment
    RestApiId: !Ref ApiGatewayRestApi
```

### Step 7: Create a AWS::IAM::Role resource for the API Gateway

```yaml
ApiGatewayIamRole:
  Type: AWS::IAM::Role
  Properties:
    AssumeRolePolicyDocument:
      Version: '2012-10-17'
      Statement:
        - Sid: ''
          Effect: 'Allow'
          Principal:
            Service:
              - 'apigateway.amazonaws.com'
          Action:
            - 'sts:AssumeRole'
    Path: '/'
    Policies:
      - PolicyName: LambdaAccess
        PolicyDocument:
          Version: '2012-10-17'
          Statement:
            - Effect: 'Allow'
              Action: 'lambda:*'
              Resource: !GetAtt LambdaFunction.Arn
```

**Note**: This IAM role allows the API Gateway to call the Lambda function.

### Step 8: Create an AWS Lambda function

```yaml
LambdaFunction:
  Type: AWS::Lambda::Function
  Properties:
    Code:
      ZipFile: |
        def handler(event, context):
          response = {
            'isBase64Encoded': False,
            'statusCode': 200,
            'headers': {},
            'multiValueHeaders': {},
            'body': 'Hello, World!'
          }
          return response
    Description: AWS Lambda function
    FunctionName: 'lambda-function'
    Handler: index.handler
    MemorySize: 256
    Role: !GetAtt LambdaIamRole.Arn
    Runtime: python3.7
    Timeout: 60
```

### Step 9: Create a AWS::IAM::Role resource for the Lambda function

```yaml
LambdaIamRole:
  Type: AWS::IAM::Role
  Properties:
    AssumeRolePolicyDocument:
      Version: '2012-10-17'
      Statement:
        - Effect: 'Allow'
          Principal:
            Service:
              - 'lambda.amazonaws.com'
          Action:
            - 'sts:AssumeRole'
    Path: '/'
```

**Note**: This IAM role does not currently give the Lambda function access to any AWS resources.

### A classic chicken and egg problem
There are two ways to deploy a Lambda function using CloudFormation:

1. Inline
2. Using Amazon S3

#### Inline
For Node.js and Python functions, you can specify the function code inline in the template. This can be accomplished by using the [*literal style*](https://yaml.org/spec/1.2/spec.html#id2795688) block indicator (`|`).

#### Using Amazon S3
Additionally, you can specify the location of a deployment package in Amazon S3. This is where a Lambda deployment can become cumbersome, as it is impossible to define a Lambda function resource *and* the S3 bucket from which the Lambda function deployment package is retrieved in the same CloudFormation template.

Instead, you must first deploy the CloudFormation stack with the S3 bucket, put the Lambda function deployment package in the S3 bucket, then specify the S3 bucket and object key in the CloudFormation template for the Lambda function resource before deploying the template again.

### Putting it all together

The final CloudFormation template is as follows:

`template.yaml`

```yaml
AWSTemplateFormatVersion: '2010-09-09'

Description: AWS API Gateway with a Lambda Integration

Resources:

  ApiGatewayRestApi:
    Type: AWS::ApiGateway::RestApi
    Properties:
      ApiKeySourceType: HEADER
      Description: An API Gateway with a Lambda Integration
      EndpointConfiguration:
        Types:
          - EDGE
      Name: lambda-api

  ApiGatewayResource:
    Type: AWS::ApiGateway::Resource
    Properties:
      ParentId: !GetAtt ApiGatewayRestApi.RootResourceId
      PathPart: 'lambda'
      RestApiId: !Ref ApiGatewayRestApi

  ApiGatewayMethod:
    Type: AWS::ApiGateway::Method
    Properties:
      ApiKeyRequired: false
      AuthorizationType: NONE
      HttpMethod: POST
      Integration:
        ConnectionType: INTERNET
        Credentials: !GetAtt ApiGatewayIamRole.Arn
        IntegrationHttpMethod: POST
        PassthroughBehavior: WHEN_NO_MATCH
        TimeoutInMillis: 29000
        Type: AWS_PROXY
        Uri: !Sub 'arn:aws:apigateway:${AWS::Region}:lambda:path/2015-03-31/functions/${LambdaFunction.Arn}/invocations'
      OperationName: 'lambda'
      ResourceId: !Ref ApiGatewayResource
      RestApiId: !Ref ApiGatewayRestApi

  ApiGatewayModel:
    Type: AWS::ApiGateway::Model
    Properties:
      ContentType: 'application/json'
      RestApiId: !Ref ApiGatewayRestApi
      Schema: {}

  ApiGatewayStage:
    Type: AWS::ApiGateway::Stage
    Properties:
      DeploymentId: !Ref ApiGatewayDeployment
      Description: Lambda API Stage v0
      RestApiId: !Ref ApiGatewayRestApi
      StageName: 'v0'

  ApiGatewayDeployment:
    Type: AWS::ApiGateway::Deployment
    DependsOn: ApiGatewayMethod
    Properties:
      Description: Lambda API Deployment
      RestApiId: !Ref ApiGatewayRestApi

  ApiGatewayIamRole:
    Type: AWS::IAM::Role
    Properties:
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Sid: ''
            Effect: 'Allow'
            Principal:
              Service:
                - 'apigateway.amazonaws.com'
            Action:
              - 'sts:AssumeRole'
      Path: '/'
      Policies:
        - PolicyName: LambdaAccess
          PolicyDocument:
            Version: '2012-10-17'
            Statement:
              - Effect: 'Allow'
                Action: 'lambda:*'
                Resource: !GetAtt LambdaFunction.Arn

  LambdaFunction:
    Type: AWS::Lambda::Function
    Properties:
      Code:
        ZipFile: |
          def handler(event, context):
            response = {
              'isBase64Encoded': False,
              'statusCode': 200,
              'headers': {},
              'multiValueHeaders': {},
              'body': 'Hello, World!'
            }
            return response
      Description: AWS Lambda function
      FunctionName: 'lambda-function'
      Handler: index.handler
      MemorySize: 256
      Role: !GetAtt LambdaIamRole.Arn
      Runtime: python3.7
      Timeout: 60

  LambdaIamRole:
    Type: AWS::IAM::Role
    Properties:
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: 'Allow'
            Principal:
              Service:
                - 'lambda.amazonaws.com'
            Action:
              - 'sts:AssumeRole'
      Path: '/'
```

## Validating and deploying the CloudFormation stack

```bash
$ aws cloudformation validate-template \
--template-body file://template.yaml
```

```bash
$ aws cloudformation deploy \
--stack-name lambda-api \
--template-file template.yaml \
--capabilities CAPABILITY_IAM
```

## Testing the API Gateway

Once our API Gateway is deployed, testing simply involves making a request to the endpoint:

```bash
$ http -v POST \
https://ld47kkph0k.execute-api.us-east-1.amazonaws.com/v0/lambda
POST /v0/lambda HTTP/1.1
Accept: */*
Accept-Encoding: gzip, deflate
Connection: keep-alive
Content-Length: 0
Host: ld47kkph0k.execute-api.us-east-1.amazonaws.com
User-Agent: HTTPie/1.0.2



HTTP/1.1 200 OK
Connection: keep-alive
Content-Length: 13
Content-Type: application/json
Date: Sat, 23 Mar 2019 18:42:40 GMT
Via: 1.1 e9dbb62af8eec6cb13379a137374c506.cloudfront.net (CloudFront)
X-Amz-Cf-Id: inzNnrULgCdovDrCLZ8SJvOJpUP7HZOIxO03Bey5ime--PLwTD8YtA==
X-Amzn-Trace-Id: Root=1-5c967e1f-d5965300732188ec019219b0;Sampled=0
X-Cache: Miss from cloudfront
x-amz-apigw-id: XAik_GQQoAMF6kw=
x-amzn-RequestId: 6f9d4c82-4d9b-11e9-9895-2fd0d402e35d

Hello, World!
```

**Note**: I like to use [HTTPie](https://httpie.org/). You can install it simply via Homebrew:

```bash
brew install httpie
```

## Conclusion
You now have an API Gateway with a Lambda proxy integration! Although this API and Lambda function do not do anything useful, it provides a pattern for architecting a system that is more robust. Other AWS resources are not at your disposal through the use of the Lambda function and are accessible via a configurable and publicly accessible API Gateway.

The code for this CloudFormation stack, as well as other CloudFormation templates can be found at [nickolashkraus/cloudformation-templates](https://github.com/nickolashkraus/cloudformation-templates).
