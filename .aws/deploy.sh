#!/bin/bash
#
# Deploy nickolaskraus.org to AWS
#
# usage: deploy.sh
#

# remove static files
rm -rf $PWD/public

# build static files
hugo

# remove files from S3
aws s3 rm s3://$S3_BUCKET_ROOT --recursive

# sync files with S3
aws s3 sync --acl "public-read" public/ s3://$S3_BUCKET_ROOT

# invalidate cloudfront cache
aws cloudfront create-invalidation --distribution-id $CF_DISTRIBUTION_ID --paths "/*"
