variable "cloudfront_prefix_list_ipv4" {
  description = "CloudFront IPv4 prefix list ID for security group rules"
  default = "pl-a3a144ca" # com.amazonaws.global.cloudfront.origin-facing (IPv4)
  # Hardcode them in Terraform as variables (IDs don’t change unless AWS does a breaking change)
  # aws ec2 describe-managed-prefix-lists --region eu-central-1 --query "PrefixLists[].{Name:PrefixListName,ID:PrefixListId}" --output table
}

variable "region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "eu-central-1"
}

variable "container_image" {
  description = "The Docker image (e.g. ECR URI)"
  type        = string
}

variable "database_name" {
  description = "database name"
  type        = string
  default     = "tripdb"
}

variable "allowed_origin" {
  description = "Allowed origin : domain that is explicitly permitted to access resources  in the context of Cross-Origin Resource Sharing (CORS)"
  type        = string
}

variable "cookie_secure_attribute" {
  description = "Cookie is visible for Http only"
  type        = bool
  default     = true
}

variable "cookie_same_site" {
  description = "Cookie same site"
  type        = string
  default     = "Lax"
}

variable "super_admin_fullname" {
  description = "Fullname of bootstrapped SuperAdmin user when app starts"
  type        = string
}
