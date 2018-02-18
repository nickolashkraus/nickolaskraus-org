#!/bin/bash
#
# Set environment variables for AWS configuration
#
# usage: source set-aws-env.sh
#

#
# Global
#

# set domain name
export DOMAIN_NAME=nickolaskraus.org

# set canonical user id
export CANONICAL_USER_ID=7582eb3b4084d40317f555af862717b27782d077f476ded2a56ba646da07ed8d

# set region
export REGION=us-east-1

#
# Amazon S3 Configuration
#

# set bucket name for log files
export S3_BUCKET_LOGS=nickolaskraus-logs

# set bucket name for root domain
export S3_BUCKET_ROOT=nickolaskraus-root

# set logging policy JSON path
export S3_LOGGING_POLICY=/Users/$USER/Workspace/nickolaskraus-org/.aws/s3_logging_policy.json

# set website configuration JSON path
export S3_WEBSITE_CONFIG=/Users/$USER/Workspace/nickolaskraus-org/.aws/s3_website_config.json

# set bucket policy JSON path
export S3_BUCKET_POLICY=/Users/$USER/Workspace/nickolaskraus-org/.aws/s3_bucket_policy.json

# set S3 bucket domain name
export S3_DOMAIN_NAME=$S3_BUCKET_ROOT.s3-website.$REGION.amazonaws.com

#
# Amazon CloudFront Configuration
#

# set certificate ARN
export CF_CERTIFICATE_ARN=arn:aws:acm:us-east-1:185444048157:certificate/bcf95a60-a87b-4423-b860-6a5924fead18

# set DNS validation JSON path
export CF_DNS_VALIDATION=/Users/$USER/Workspace/nickolaskraus-org/.aws/cf_dns_validation.json

# set distribution JSON path
export CF_DISTRIBUTION=/Users/$USER/Workspace/nickolaskraus-org/.aws/cf_distribution.json

# set CloudFront distribution domain name
export CF_DOMAIN_NAME=dfgyhavmcf7qg.cloudfront.net

#
# Amazon Route 53 Configuration
#

# set domain domain duration
export R53_DOMAIN_DURATION=1

# set domain contact (admin, registrant, tech) information JSON path
export R53_CONTACT_INFO=/Users/$USER/Workspace/nickolaskraus-org/.aws/r53_contact_info.json

# set hosted zone id
export R53_HOSTED_ZONE_ID=Z3OMX3SLNACZXW

# set DNS configuration JSON path
export R53_DNS_CONFIG=/Users/$USER/Workspace/nickolaskraus-org/.aws/r53_dns_config.json
