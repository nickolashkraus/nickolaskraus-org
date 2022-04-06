---
title: "Understanding Amazon Security Groups - Part 2"
date: 2019-06-23T00:00:00-06:00
draft: false
description: In this article, we deepen our understanding of Amazon security groups. In addition, we take a look at the differences between EC2-Classic and EC2-VPC security groups.
---

In my previous article, we looked at the basics of Amazon security groups, which control traffic to and from an EC2 instance. In this article, we deepen our understanding of Amazon security groups and attempt to elucidate the differences between EC2-Classic security groups and EC2-VPC security groups.

## What Is Amazon VPC?
First, let’s get a quick overview of Amazon VPC. Amazon Virtual Private Cloud (Amazon VPC) enables you to launch AWS resources into a virtual network that you’ve defined. This virtual network closely resembles a traditional network — you can establish subnets, define routing tables, and create network gateways. The benefit is that you can leverage Amazon’s scalable infrastructure that is logically isolated from other virtual networks within AWS.

Your AWS account is provisioned with a *default* Amazon VPC and a *default* security group. This security group allows all inbound traffic from instances assigned to the same security group and allows all outbound traffic to any IPv4 and IPv6 address. If a specific subnet is not specified, an instance is launched into your default VPC and the default security group is associated with this instance.

It should be noted that the EC2-Classic platform was introduced in the original release of Amazon EC2. If you created your AWS account after December 4th, 2013, it does not support EC2-Classic, so you must launch your Amazon EC2 instances in a VPC. Therefore, if you are creating EC2 instances after December 4th, 2013, they are most likely being deployed to the new VPC architecture. Only when dealing with legacy infrastructure does one need to consider the differences between EC2-Classic and EC2-VPC security groups.

## Nomenclature Confusion
It should be noted that the terms *VPC security group* and *EC2 security group* are used interchangeably in the Amazon documentation. This may be somewhat confusing. One could realistically assume that an *EC2 security group* applies to an instance, whereas a *VPC security group* applies to a VPC. This is not the case. A security group, whether it be referred to as an EC2 or VPC security group, acts exclusively on one or more instances. A network ACL, on the other hand, allows you to define rules similar to a security group, but can be applied to a VPC. We will look at the differences between security groups and network ACLs in a later section.

This confusing nomenclature arose from the transition from the EC2-Classic to EC2-VPC architecture. There *are* differences between EC2-Classic and EC2-VPC security groups (we will discuss these differences in a later section), however one should assume that when referring to security groups, they will most likely always be EC2-VPC security groups.

Going forward, I will refer to Amazon security groups simply as *security groups* and only use the EC2-Classic and EC2-VPC naming convention when drawing attention to differences in their functionality.

## Security Group Overview
A *security group* acts as a virtual firewall for your instance to control inbound and outbound traffic. When you launch an instance in a VPC, you can assign up to five security groups to the instance. For each security group, you add *rules* that control the inbound traffic to instances, and a separate set of rules that control the outbound traffic. It is helpful to note that *only* EC2-VPC security groups allow you to define egress rules as well as ingress rules.


## Security Group Basics
The following are the basic characteristics of security groups:

* You have limits on the number of security groups that you can create per VPC, the number of rules that you can add to each security group, and the number of security groups you can associate with a network interface. For more information, see [Amazon VPC Limits](https://docs.aws.amazon.com/vpc/latest/userguide/amazon-vpc-limits.html).
* You can specify *allow* rules, but not *deny* rules.
* You can specify separate rules for inbound and outbound traffic.
* When you create a security group, it has no inbound rules. Therefore, no inbound traffic originating from another host to your instance is allowed until you add inbound rules to the security group.
* By default, a security group includes an outbound rule that allows all outbound traffic. You can remove the rule and add outbound rules that allow specific outbound traffic only. If your security group has no outbound rules, no outbound traffic originating from your instance is allowed.
* Security groups are stateful — if you send a request from your instance, the response traffic for that request is allowed to flow in regardless of inbound security group rules. Responses to allowed inbound traffic are allowed to flow out, regardless of outbound rules. **Note**: Some types of traffic are tracked differently to others. For more information, see [Connection Tracking](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-network-security.html#security-group-connection-tracking).
* Instances associated with a security group can’t talk to each other unless you add rules allowing it. **Note**: The *default* security group has these rules by default.
* Security groups are associated with network interfaces. After you launch an instance, you can change the security groups associated with the instance, which changes the security groups associated with the primary network interface (`eth0`). You can also change the security groups associated with any other network interface.

## Default Security Group
Your VPC automatically comes with a *default* security group eponymously given the group name *default*. If you don’t specify a security group when you launch an EC2 instance, the instance is automatically associated with this security group.

The following table describes the default rules for the default security group:

### Inbound

| **Source** | **Protocol** | **Port Range** | **Comments** |
|------------|--------------|----------------|--------------|
| The security group ID (`sg-xxxxxxxx`) | All | All | Allow inbound traffic from instances assigned to the same security group. |

### Outbound

| **Destination** | **Protocol** | **Port Range** | **Comments** |
|-----------------|--------------|----------------|--------------|
| 0.0.0.0/0 | All | All | Allow all outbound IPv4 traffic. |
| ::/0 | All | All | Allow all outbound IPv6 traffic. This rule is added by default if you create a VPC with an IPv6 CIDR block or if you associate an IPv6 CIDR block with your existing VPC. |

**Note**: You can change the rules for the default security group, however you can’t delete a default security group.

## Security Group Rules
You can add or remove rules for a security group (also referred to as *authorizing* or *revoking* inbound or outbound access). A rule applies either to inbound traffic (ingress) or outbound traffic (egress).

The following are the basic characteristics of security group rules:

* You can specify any protocol that has a standard protocol number (for a list, see [Protocol Numbers](http://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml) ). If you specify ICMP as the protocol, you can specify any or all of the ICMP types and codes.
* When you specify a CIDR block as the source for a rule, traffic is allowed from the specified addresses for the specified protocol and port.
* When you specify a security group as the source for a rule, traffic is allowed from the elastic network interfaces (ENI) for the instances associated with the source security group for the specified protocol and port. Adding a security group as a source does not add rules from the source security group.
* If you specify a single IPv4 address, specify the address using the `/32` prefix length. If you specify a single IPv6 address, specify it using the `/128` prefix length.
* When you add or remove rules, they are automatically applied to all instances associated with the security group.
* Some systems for setting up firewalls let you filter on source ports. Security groups let you filter only on destination ports.

**Inbound rules only**

* Inbound rules designate the source of the traffic and the destination port or port range. The source can be another security group, an IPv4 or IPv6 CIDR block, or a single IPv4 or IPv6 address.

**Outbound rules only**

* Outbound rules designate the destination for the traffic and the destination port or port range. The destination can be another security group, an IPv4 or IPv6 CIDR block, a single IPv4 or IPv6 address, or a prefix list ID.


## Example Security Group Rules

### Inbound

| **Source** | **Protocol** | **Port Range** | **Comments** |
|------------|--------------|----------------|-------------|
| 0.0.0.0/0 | TCP | 80 | Allow inbound HTTP access from all IPv4 addresses |
| 0.0.0.0/0 | TCP | 443 | Allow inbound HTTPS access from all IPv4 addresses |
| Your network's public IPv4 address range | TCP | 22 | Allow inbound SSH access to Linux instances from IPv4 IP addresses in your network (over the Internet gateway) |
| Your network's public IPv4 address range | TCP | 3389 | Allow inbound RDP access to Windows instances from IPv4 IP addresses in your network (over the Internet gateway) |

### Outbound

| **Destination** | **Protocol** | **Port Range** | **Comments** |
|-----------------|--------------|----------------|--------------|
| The ID of the security group for your MySQL database servers | TCP | 3306 | Allow outbound MySQL access to instances in the specified security group |

For examples of security group rules for specific kinds of access, see [Security Group Rules Reference](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/security-group-rules-reference.html).

## Differences Between EC2-Classic and EC2-VPC Security Groups

| **Characteristic** | **EC2-Classic** | **Default VPC** | **Nondefault VPC** |
|--------------------|-----------------|-----------------|--------------------|
| Security group | A security group can reference security groups that belong to other AWS accounts. | A security group can reference security groups for your VPC only. | A security group can reference security groups for your VPC only. |
| Security group association | You can assign an unlimited number of security groups to an instance when you launch it, however you can’t change the security groups of your running instance. | You can assign up to 5 security groups to an instance. You can assign security groups to your instance when you launch it and while it’s running. | You can assign up to 5 security groups to an instance. You can assign security groups to your instance when you launch it and while it’s running. |
| Security group rules | You can add rules for inbound traffic only. | You can add rules for inbound and outbound traffic. | You can add rules for inbound and outbound traffic. |

## Comparison of Security Groups and Network ACLs
The following table summarizes the basic differences between security groups and network ACLs.

| **Security Group** | **Network ACL** |
|--------------------|-----------------|
| Operates at the instance level | Operates at the subnet level |
| Supports allow rules only | Supports allow rules and deny rules |
| Is stateful: Return traffic is automatically allowed, regardless of any rules | Is stateless: Return traffic must be explicitly allowed by rules |
| We evaluate all rules before deciding whether to allow traffic | We process rules in number order when deciding whether to allow traffic |
| Applies to an instance only if someone specifies the security group when launching the instance, or associates the security group with the instance later on | Automatically applies to all instances in the subnets it’s associated with (therefore, you don’t have to rely on users to specify the security group) |

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
    VpcId: !Ref VpcId

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

**Note**: If you are deploying an EC2 instance to a VPC and you do *not* specify a `VpcId`, the security group is added to the *default* Amazon VPC for your account.
