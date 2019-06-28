---
title: "Understanding Amazon Security Groups - Part 1"
date: 2019-06-16T12:00:00-06:00
draft: false
description: A security group acts as a virtual firewall that controls the traffic for one or more instances. This article discusses the important concepts for working with security groups in AWS.
---

## Overview
A *security group* acts as a virtual firewall that controls the traffic for one or more instances. You can add rules to each security group that allow traffic to or from its associated instances.

Security groups are associated with network interfaces. Changing an instance’s security groups changes the security groups associated with the primary network interface (`eth0`).

## Security Group Rules
The *rules* of a security group control the inbound traffic that’s allowed to reach the instances that are associated with the security group and the outbound traffic that’s allowed to leave them.

The following are the characteristics of security group rules:

* By default, security groups allow *all* outbound traffic.
* Security group rules are always permissive; you can’t create rules that deny access.
* Security groups are stateful — if you send a request from your instance, the response traffic for that request is allowed to flow in regardless of inbound security group rules.

For each rule, you specify the following:

|  |  |
|---|---|
| **Protocol** | The protocol to allow. The most common protocols are 6 (TCP), 17 (UDP), and 1 (ICMP). |
| **Port Range** | For TCP, UDP, or a custom protocol, the range of ports to allow. You can specify a single port number (for example 22), or a range of port numbers (for example, 7000-8000). |
| **ICMP Type and Code** | For ICMP, the ICMP type and code. |
| **Source or Destination**  | The source (inbound rules) or destination (outbound rules) for the traffic. |
| **(Optional) Description** | Description for the rule. |

The **source** or **destination** can be one of the following options:

* An individual IPv4 address. You must use the `/32` prefix.
* An individual IPv6 address. You must use the `/128` prefix.
* A range of IPv4 addresses, in CIDR block notation.
* A range of IPv6 addresses, in CIDR block notation.
* The prefix list ID for an AWS service.
* Another security group.

Using another security group as the source or destination allows instances associated with the specified security group to access instances associated with this security group.

## Connection Tracking
Your security groups use connection tracking to track information about traffic to and from the instance. Rules are applied based on the connection state of the traffic to determine if the traffic is allowed or denied. This allows security groups to be stateful — responses to inbound traffic are allowed to flow out of the instance regardless of outbound security group rules, and vice versa. For example, if you initiate an ICMP `ping` command to your instance from your home computer, and your inbound security group rules allow ICMP traffic, information about the connection (including the port information) is tracked. Response traffic from the instance for the `ping` command is not tracked as a new request, but rather as an established connection and is allowed to flow out of the instance, even if your outbound security group rules restrict outbound ICMP traffic.

Not all flows of traffic are tracked. If a security group rule permits TCP or UDP flows for all traffic (0.0.0.0/0) and there is a corresponding rule in the other direction that permits all response traffic (0.0.0.0/0) for all ports (0-65535), then that flow of traffic is not tracked. The response traffic is therefore allowed to flow based on the inbound or outbound rule that permits the response traffic and not on tracking information.

ICMP traffic is always tracked, regardless of rules. If you remove the outbound rule from the security group, then all traffic to and from the instance is tracked, including traffic on port 80 (HTTP).

## Default Security Groups
Your AWS account automatically has a *default* security group for the default VPC in each region. If you don’t specify a security group when you launch an EC2 instance, the instance is automatically associated with the default security group for the VPC.

The default security group is named *default*, and it has an ID assigned by AWS. The following are the default rules for the default security group:

* Allows all inbound traffic from other instances associated with the default security group (the security group specifies itself as a source security group in its inbound rules).
* Allows all outbound traffic from the instance.

## Custom Security Groups
If you don’t want your instances to use the default security group, you can create your own security groups and specify them when you launch your instances. You can create multiple security groups to reflect the different roles that your instances play; for example, a web server or a database server.

The following are the default rules for a security group that you create:

* Allows no inbound traffic.
* Allows all outbound traffic.

## Security Group Rules Reference
A reference for configuring security groups for specific use cases can be found [here](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/security-group-rules-reference.html).

## Example CloudFormation Security Group
The following CloudFormation template defines a security group that allows *all* inbound HTTP and HTTPS traffic from *any* IPv4 address or IPv6 address:

```yaml
EC2SecurityGroup:
  Type: AWS::EC2::SecurityGroup
  Properties:
    GroupName: !Sub '${AWS::StackName}-sg'
    SecurityGroupIngress:
      - !Ref EC2SecurityGroupIngressHttp
      - !Ref EC2SecurityGroupIngressHttps

EC2SecurityGroupIngressHttp:
  Type: AWS::EC2::SecurityGroupIngress
  Properties:
    CidrIp: 0.0.0.0/0
    CidrIpv6: ::/0
    Description: Allow HTTP access
    FromPort: 80
    GroupId: !GetAtt EC2SecurityGroup.GroupId
    IpProtocol: 6
    ToPort: 80

EC2SecurityGroupIngressHttps:
  Type: AWS::EC2::SecurityGroupIngress
  Properties:
    CidrIp: 0.0.0.0/0
    CidrIpv6: ::/0
    Description: Allow HTTP access
    FromPort: 443
    GroupId: !GetAtt EC2SecurityGroup.GroupId
    IpProtocol: 6
    ToPort: 443
```
