output "cloudfront_domain_name" {
  description = "Domain name of the CloudFront distribution for the NLB"
  value       = aws_cloudfront_distribution.cdn.domain_name
}