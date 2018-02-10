#!/bin/bash
#
# Set environment variables for AWS configuration
#
# usage: set-aws-env
#

#
# Global
#

# set canonical user id
export CANONICAL_USER_ID=7582eb3b4084d40317f555af862717b27782d077f476ded2a56ba646da07ed8d

# set region
export REGION=us-east-1

#
# Amazon S3 Configuration
#

# set s3 bucket name for log files
export BUCKET_LOGS=nickolaskraus-awscli-logs

# set s3 bucket name for root domain
export BUCKET_ROOT=nickolaskraus-awscli-root

# set s3 bucket name for input files
export BUCKET_INPUT=nickolaskraus-awscli-input

# set logging policy JSON path
export LOGGING_POLICY=/Users/$USER/Workspace/nickolaskraus-org/.aws/logging.json

# set website configuration JSON path
export WEBSITE_CONFIG=/Users/$USER/Workspace/nickolaskraus-org/.aws/website.json

# set bucket policy JSON path
export BUCKET_POLICY=/Users/$USER/Workspace/nickolaskraus-org/.aws/policy.json

#
# Amazon CloudFront Configuration
#

# set region
export CERTIFICATE_REGION=us-east-1

# set domain name
export DOMAIN_NAME=nickolaskraus-awscli.org

# set certificate ARN
export CERTIFICATE_ARN=arn:aws:acm:us-east-1:185444048157:certificate/f1a83376-fae8-4ffc-ab3d-58f9e85c71f6

# set DNS validation JSON path
export DNS_VALIDATION=/Users/$USER/Workspace/nickolaskraus-org/.aws/dns_validation.json

# set CloudFront Distribution domain name
export CF_DOMAIN_NAME=nickolaskraus-awscli.org

# set distribution JSON path
export CF_DISTRIBUTION=/Users/$USER/Workspace/nickolaskraus-org/.aws/distribution.json

#
# Amazon Route 53 Configuration
#

# set region
export DOMAIN_REGION=us-east-1

# set domain name
export DOMAIN_NAME=nickolaskraus-awscli.org

# set domain domain duration
export DOMAIN_DURATION=1

# set domain contact (admin, registrant, tech) information JSON path
export CONTACT_INFO=/Users/$USER/Workspace/nickolaskraus-org/.aws/contact.json

# set hosted zone id
export HOSTED_ZONE_ID=Z1E9RPNBG99QWU

# set DNS configuration JSON path
export DNS_CONFIG=/Users/$USER/Workspace/nickolaskraus-org/.aws/dns_config.json
