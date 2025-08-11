#!/bin/bash
set -e

CLOUDFRONT_URL="your-cloudfront-url.cloudfront.net"

# Replace placeholder in built index.html
echo "Injecting CloudFront URL into index.html..."
sed -i "s|__API_URL_PLACEHOLDER__|https://${CLOUDFRONT_URL}|g" ../dist/index.html

# Upload to S3 (adjust bucket name and path as needed)
echo "Uploading files to S3..."
aws s3 sync ./dist/ s3://prod-trip-design-app-bucket/ --delete

echo "Frontend deployed successfully!"
