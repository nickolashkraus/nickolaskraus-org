---
title: "Creating an Amazon API Gateway with a Mock Integration using CloudFormation"
date: 2019-01-27T00:00:00-06:00
draft: false
description: Amazon API Gateway is a highly useful and powerful tool. However, mastering its functionality is not easy. This article attempts to elucidate the major concepts of Amazon API Gateway by guiding the reader through the creation of an API Gateway with a mock integration.
---

I’ll be honest, it took me many hours to get my head around Amazon API Gateway and about just as long to get a simple mock API set up correctly. Nevertheless, once one understands the main thrust of this resource, namely the request/response pattern (I will discuss this pattern in detail), it becomes a highly useful and powerful tool.

## Overview
With Amazon API Gateway, you build an API as a collection of programmable entities known as API Gateway [resources](https://docs.aws.amazon.com/apigateway/api-reference/resource/). API Gateway resources are not to be confused with the CloudFormation API Gateway Resource ([`AWS::ApiGateway::Resource`](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-apigateway-resource.html)), though the latter is considered an API Gateway resource as well. The following list gives a brief summary of the resources our API Gateway will require.

**Note**: The reader should be aware of a possible point of confusion with regard to how AWS taxonomizes API Gateway resources. Some resources constitute AWS resources, while others are properties *of* those resources. I have designated each as either a resource or property below.

### RestApi
* **Type**: Resource

A `RestApi` is a collection of HTTP resources and methods that are integrated with backend HTTP endpoints, Lambda functions, or other AWS services. Typically, API resources are organized in a resource tree according to the application logic. Each API resource can expose one or more API methods that have unique HTTP verbs supported by API Gateway.

In CloudFormation, the [`AWS::ApiGateway::RestApi`](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-apigateway-restapi.html) resource is used to define an Amazon API Gateway `RestApi`.

### Resource
* **Type**: Resource

A `Resource` is an AWS conceptualization of a REST API *resource*. A *resource* is a fundamental concept of RESTful APIs and represents an object with a type, associated data, relationships to other resources, and a set of methods that operate on it. A resource contains HTTP methods, for example, `GET`, `POST`, `PUT` and `DELETE` methods.

In CloudFormation, the [`AWS::ApiGateway::Resource`](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-apigateway-resource.html) resource is used to define an Amazon API Gateway `Resource`.

### Method
* **Type**: Resource

A `Method`defines the application programming interface for the client to access the exposed `Resource` and represents an incoming request submitted by the client. A `Method` is expressed using request parameters and body.

In CloudFormation, the [`AWS::ApiGateway::Method`](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-apigateway-method.html) resource is used to define an Amazon API Gateway `Method`.

### Integration
* **Type**: Property
* **Parent**: `Method`

An `Integration` is used to integrate the `Method` with a backend endpoint, also known as the integration endpoint, by forwarding the incoming request to a specified integration endpoint URI. If necessary, you transform request parameters or body to meet the backend requirements.

In CloudFormation, the [`Integration`](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-apigateway-method.html#cfn-apigateway-method-integration) property is used to define an Amazon API Gateway `Integration`.

### IntegrationResponse
* **Type**: Property
* **Parent**: `Integration`

An `IntegrationResponse` is used to represent the request response that is returned by the backend. You can configure the integration response to transform the backend response data before returning the data to the client or to pass the backend response as-is to the client. API Gateway intercepts the response from the backend so that you can control how API Gateway surfaces backend responses. For example, you can map the backend status codes to codes that you define.

In CloudFormation, the [`IntegrationResponse`](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-apitgateway-method-integration.html#cfn-apigateway-method-integration-integrationresponses) property is used to define an Amazon API Gateway `IntegrationResponse`.

### MethodResponse
* **Type**: Property
* **Parent**: `Method`

A `MethodResponse` resource is used to represent a request response received by the client.

In CloudFormation, the [`MethodResponse`](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-apigateway-method.html#cfn-apigateway-method-methodresponses) property is used to define an Amazon API Gateway `MethodResponse`.

### Model
* **Type**: Resource

A `Model` defines the data structure of a payload. In API Gateway, `Model`s enable basic request validation for your API. They are defined using the [JSON Schema v4](https://tools.ietf.org/html/draft-zyp-json-schema-04).

`Model`s can also be used in conjunction with [Mappings](https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-mapping-template-reference.html). Mappings allow you to map the payload from a method request to the corresponding integration request and from an integration response to the corresponding method response. You do not have to define a `Model` to create a mapping template. However, a `Model` can help you create a template because API Gateway will generate a template blueprint based on a provided `Model`.

In CloudFormation, the [`AWS::ApiGateway::Model`](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-apigateway-model.html) resource is used to define an Amazon API Gateway `Model`.

### Stage
* **Type**: Resource

A `Stage` represents a snapshot of the API, including methods, integrations, models, mapping templates, Lambda authorizers (formerly known as custom authorizers), etc. and is reference by a deployment. You use a `Stage` to manage and optimize a particular deployment. For example, you can set up stage settings to enable caching, customize request throttling, configure logging, define stage variables or attach a canary release for testing.

In CloudFormation, the [`AWS::ApiGateway::Stage`](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-apigateway-stage.html) resource is used to define an Amazon API Gateway `Stage`.

### Deployment
* **Type**: Resource

A `Deployment` is like an executable of an API represented by a `RestApi` resource. Creating a `Deployment` simply amounts to instantiating the `Deployment` resource. For the client to call your API, you must create a `Deployment` and associate a `Stage` with it.

In CloudFormation, the [`AWS::ApiGateway::Deployment`](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-apigateway-deployment.html) resource is used to define an Amazon API Gateway `Deployment`.

## Creating the CloudFormation template
The following sections provide further information on each of these resources and how they are put together to create a REST API.

### Step 1: Create a ApiGateway::RestApi resource

`AWS::ApiGateway::RestApi` has the following form:

```yaml
ApiGatewayRestApi:
  Type: AWS::ApiGateway::RestApi
  Properties:
    ApiKeySourceType: HEADER
    Description: An API Gateway with a Mock Integration
    EndpointConfiguration:
      Types:
        - EDGE
    Name: mock-api
```

* The only required property is `Name`, which itself is only required if you do not specify an OpenAPI definition.
* `ApiKeySourceType` and `EndpointConfiguration:Types` default to `HEADER` and `EDGE`, respectively, and are only provided for added clarity.
* The `ApiKeySourceType` of `HEADER` specifies that the API key be read from the `X-API-Key` header of a request.
* An edge-optimized API endpoint is best for geographically distributed clients. API requests are routed to the nearest CloudFront Point of Presence (POP).
* When deployed, the API is region-specific. For an edge-optimized API, the base URL has the following format:

	`http[s]://{restapi-id}.execute-api.amazonaws.com/stage`

where `{restapi-id}` is the API's id value generated by API Gateway.

* Additionally, you can assign a custom domain name (for example, `apis.example.com`) as the API's host name and call the API with a base URL of the `https://apis.example.com` format.

### Step 2: Create a ApiGateway::Resource resource

`AWS::ApiGateway::Resource` has the following form:

```yaml
ApiGatewayResource:
  Type: AWS::ApiGateway::Resource
  Properties:
    ParentId: !GetAtt ApiGatewayRestApi.RootResourceId
    PathPart: 'mock'
    RestApiId: !Ref ApiGatewayRestApi
```

* As previously stated, a `Resource` is an AWS conceptualization of a REST API *resource*.
* It is possible to append a child resource under the root or parent resource by simply specifying the `ParentId` property. This is analogous to appending a path segment to the URI.
* Since, our resource, `mock`, is appended onto the root, the root resource of the `RestApi` is used by invoking the return value of the resource (`RootResourceId`).
* To make a path part a path parameter, enclose it in a pair of curly brackets.

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
      IntegrationResponses:
        - ResponseTemplates:
            application/json: "{\"message\": \"OK\"}"
          SelectionPattern: '2\d{2}'
          StatusCode: 200
        - ResponseTemplates:
            application/json: "{\"message\": \"Internal Server Error\"}"
          SelectionPattern: '5\d{2}'
          StatusCode: 500
      PassthroughBehavior: WHEN_NO_TEMPLATES
      RequestTemplates:
        application/json: "{\"statusCode\": $input.json('$.statusCode'), \"message\": $input.json('$.message')}"
      Type: MOCK
      TimeoutInMillis: 29000
    MethodResponses:
      - ResponseModels:
          application/json: !Ref ApiGatewayModel
        StatusCode: 200
      - ResponseModels:
          application/json: !Ref ApiGatewayModel
        StatusCode: 500
    OperationName: 'mock'
    ResourceId: !Ref ApiGatewayResource
    RestApiId: !Ref ApiGatewayRestApi
```

This is where the API Gateway can become confusing, so let’s break down the various properties comprised in `ApiGateway::Method`.

An `ApiGateway::Method` comprises four key elements:

* Method Request
* Integration Request
* Integration Response
* Method Response

The *Method Request* is the public interface of your API. This is the API definition that is exposed to your users. This API definition includes authorization and definition of the HTTP verbs that allow an input body, headers, and query string parameters. The client request can be modified using `RequestModels`, so that the public API need not mirror the request made to the back end which will handle the request.

The *Integration Request* specifies how the API Gateway will communicate with the integration. This includes the type of back end your method is running (e.g. Lambda, HTTP, AWS service, or Mock) and how the request data should be transferred before it’s sent to your method’s back end. For example, Lambda function cannot receive headers or query string parameters, but your can use API Gateway to build a JSON event for Lambda that contains all the request values.

After your method’s back end processes a request, API Gateway intercepts the response. The *Integration Response* specifies how the response codes such as Lambda errors and HTTP status codes from your method’s back end are mapped to the status codes that you defined for your method in API Gateway. You can use the integration response to read headers from your HTTP back end response and place them in the body of the response for you API consumers.

Similar to the method request, you can use the *Method Response* to define the public interface of your API. For example, you can specify which HTTP status codes the method supports, and, for each status code, which body model and header the method can return. The values for the body and headers are assigned to the fields in the integration response step.

A request made by a client has the following path:

1. The client makes a request to the public API.
2. The client request *may* be modified using request models.
3. The request is forwarded to the back end using an integration.
4. The integration request *may* be modified using request templates.
5. The back end processes the request and returns a response.
6. The back end response is mapped to an integration response.
7. The integration response is mapped to a method response.
8. The method response *may* be modified using response models.
9. The response is returned to the client.

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

* By default, API Gateway treats the message body as a text payload and applies any preconfigured mapping template to transform the JSON string. If no mapping template is specified, API Gateway can pass the text payload through to or from the integration endpoint without modification, provided that the passthrough behavior is enabled on the API method.

### Step 5: Create a AWS::ApiGateway::Stage resource

`AWS::ApiGateway::Stage` has the following form:

```yaml
ApiGatewayStage:
  Type: AWS::ApiGateway::Stage
  Properties:
    DeploymentId: !Ref ApiGatewayDeployment
    Description: Mock API Stage v0
    RestApiId: !Ref ApiGatewayRestApi
    StageName: 'v0'
```

* Don’t let the brevity of this resource fool you, `AWS::ApiGateway::Stage` resources are highly configurable and enable an API to be versioned and deployed with various configurations.

### Step 6: Create a AWS::ApiGateway::Deployment resource

`AWS::ApiGateway::Deployment` has the following form:

```yaml
ApiGatewayDeployment:
  Type: AWS::ApiGateway::Deployment
  DependsOn: ApiGatewayMethod
  Properties:
    Description: Mock API Deployment
    RestApiId: !Ref ApiGatewayRestApi
```

### Putting it all together

The final CloudFormation template is as follows:

`template.yaml`

```yaml
AWSTemplateFormatVersion: '2010-09-09'

Description: AWS API Gateway with a Mock Integration

Resources:

  ApiGatewayRestApi:
    Type: AWS::ApiGateway::RestApi
    Properties:
      ApiKeySourceType: HEADER
      Description: An API Gateway with a Mock Integration
      EndpointConfiguration:
        Types:
          - EDGE
      Name: mock-api

  ApiGatewayResource:
    Type: AWS::ApiGateway::Resource
    Properties:
      ParentId: !GetAtt ApiGatewayRestApi.RootResourceId
      PathPart: 'mock'
      RestApiId: !Ref ApiGatewayRestApi

  ApiGatewayMethod:
    Type: AWS::ApiGateway::Method
    Properties:
      ApiKeyRequired: false
      AuthorizationType: NONE
      HttpMethod: POST
      Integration:
        ConnectionType: INTERNET
        IntegrationResponses:
          - ResponseTemplates:
              application/json: "{\"message\": \"OK\"}"
            SelectionPattern: '2\d{2}'
            StatusCode: 200
          - ResponseTemplates:
              application/json: "{\"message\": \"Internal Server Error\"}"
            SelectionPattern: '5\d{2}'
            StatusCode: 500
        PassthroughBehavior: WHEN_NO_TEMPLATES
        RequestTemplates:
          application/json: "{\"statusCode\": $input.json('$.statusCode'), \"message\": $input.json('$.message')}"
        Type: MOCK
        TimeoutInMillis: 29000
      MethodResponses:
        - ResponseModels:
            application/json: !Ref ApiGatewayModel
          StatusCode: 200
        - ResponseModels:
            application/json: !Ref ApiGatewayModel
          StatusCode: 500
      OperationName: 'mock'
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
      Description: Mock API Stage v0
      RestApiId: !Ref ApiGatewayRestApi
      StageName: 'v0'

  ApiGatewayDeployment:
    Type: AWS::ApiGateway::Deployment
    DependsOn: ApiGatewayMethod
    Properties:
      Description: Mock API Deployment
      RestApiId: !Ref ApiGatewayRestApi
```

## Validating and deploying the CloudFormation stack

```bash
$ aws cloudformation validate-template \
--template-body file://template.yaml
```

```bash
$ aws cloudformation deploy \
--stack-name mock-api \
--template-file template.yaml
```

## Testing the API Gateway

Once our API Gateway is deployed, testing simply involves making a request to the endpoint:

```bash
$ http -v POST \
https://48im2qtd24.execute-api.us-east-1.amazonaws.com/v0/mock \
Content-Type:application/json \
statusCode:=200
POST /v0/mock HTTP/1.1
Accept: application/json, */*
Accept-Encoding: gzip, deflate
Connection: keep-alive
Content-Length: 19
Content-Type: application/json
Host: 48im2qtd24.execute-api.us-east-1.amazonaws.com
User-Agent: HTTPie/1.0.2

{
    "statusCode": 200
}

HTTP/1.1 200 OK
Connection: keep-alive
Content-Length: 17
Content-Type: application/json
Date: Sat, 23 Mar 2019 19:39:18 GMT
Via: 1.1 5da5773a6acab8f3aabf385b38683f20.cloudfront.net (CloudFront)
X-Amz-Cf-Id: cO0upsvpRSbBtgtsjM-QTLBYAmi5aBFzGqGh3Z3F3QgGlGLI6IF6ag==
X-Cache: Miss from cloudfront
x-amz-apigw-id: XAq39HAooAMFTGA=
x-amzn-RequestId: 591ea80d-4da3-11e9-b794-57da1a43b456

{
    "message": "OK"
}
```

```bash
$ http -v POST \
https://48im2qtd24.execute-api.us-east-1.amazonaws.com/v0/mock \
Content-Type:application/json \
statusCode:=500
POST /v0/mock HTTP/1.1
Accept: application/json, */*
Accept-Encoding: gzip, deflate
Connection: keep-alive
Content-Length: 19
Content-Type: application/json
Host: 48im2qtd24.execute-api.us-east-1.amazonaws.com
User-Agent: HTTPie/1.0.2

{
    "statusCode": 500
}

HTTP/1.1 500 Internal Server Error
Connection: keep-alive
Content-Length: 36
Content-Type: application/json
Date: Sat, 23 Mar 2019 19:39:38 GMT
Via: 1.1 a077f80f2fe737f90e09bad4a75fa2bc.cloudfront.net (CloudFront)
X-Amz-Cf-Id: DOZ-T1lUPJ4bt4mknyuDCAkZsFl_RxaLUNf3XzPxqNIthe2mjJL7yA==
X-Cache: Error from cloudfront
x-amz-apigw-id: XAq7KGiCoAMFi9g=
x-amzn-RequestId: 6550e955-4da3-11e9-96f3-530d94485ec9

{
    "message": "Internal Server Error"
}
```

**Note**: I like to use [HTTPie](https://httpie.org/). You can install it simply via Homebrew:

```bash
brew install httpie
```

## Conclusion
You now have an API Gateway with a mock integration! Although this API does not do anything useful, it provides a schema for API resources that are more robust, as they will inevitably follow the same pattern. As you may have already observed, Amazon API Gateway is incredibly extensible, but presents a steep learning curve. Hopefully this article elucidated some of the more abstruse concepts.

## Extra
When API Gateway is integrated with AWS Lambda or another AWS service, such as Amazon Simple Storage Service or Amazon Kinesis, you must also enable API Gateway as a trusted entity to invoke an AWS service in the backend. To do so, create an IAM role and attach a service-specific access policy to the role. This is demonstrated in the following example for invoking a Lambda function:

```json
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Effect":"Allow",
      "Action":"lambda:InvokeFunction",
      "Resource":"*"
    }
  ]
}
```

The code for this CloudFormation stack, as well as other CloudFormation templates can be found at [NickolasHKraus/cloudformation-templates](https://github.com/NickolasHKraus/cloudformation-templates).
