output "cloudfront_domain_name" {
  description = "Domain name of the CloudFront distribution for the NLB"
  value       = aws_cloudfront_distribution.cdn.domain_name
}

output "vpce_dns_name" {
  value = aws_vpc_endpoint.cloudfront_vpce.dns_entry[0].dns_name
}