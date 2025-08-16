resource "aws_wafv2_web_acl" "trip_planner_cloudfront_waf" {
  provider    = aws.us_east_1
  name        = "trip-planner-cloudfront-waf"
  description = "WAF for CloudFront distribution of the Trip Planner app"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "tripPlannerCloudfrontWAF"
    sampled_requests_enabled   = true
  }

  # Managed rule group: common protections
  # covers SQL injection, XSS, and other common attacks.
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "managedRules"
      sampled_requests_enabled   = true
    }
  }

  # Dynamic bot blocking rules
  dynamic "rule" {
    for_each = var.blocked_bots_waf_cloudfront
    content {
      name     = "Block${rule.value}"
      priority = 10 + index(var.blocked_bots_waf_cloudfront, rule.value) # avoid conflicts with managed rules

      statement {
        byte_match_statement {
          search_string = rule.value
          field_to_match {
            single_header {
              name = "user-agent"
            }
          }
          positional_constraint = "CONTAINS"
          text_transformation {
            priority = 0
            type     = "NONE"
          }
        }
      }

      action {
        block {}
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "Block${rule.value}"
        sampled_requests_enabled   = true
      }
    }
  }

  # Rate-based rule to limit requests per IP
  rule {
    name     = "RateLimitPerIP"
    priority = 10 + length(var.blocked_bots_waf_cloudfront) + 1 # after bot rules

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 1000 # requests per 5 minutes
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "rateLimit"
      sampled_requests_enabled   = true
    }
  }
}
