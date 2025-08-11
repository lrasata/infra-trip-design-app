module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.0"

  name = "vpc-trip-design"
  cidr = "10.0.0.0/16"

  azs             = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true # allow ECS tasks to pull images from ECR/Docker Hub and install updates
  single_nat_gateway = true
}

# CloudFront (Global) should access NLB in the VPC (no public IP) securely
# To achieve this we expose load balancer as a VPC Endpoint Service (PrivateLink).
# VPC Endpoint Service (PrivateLink) cannot directly connect on an ALB. It only supports Network Load Balancers (NLBs
resource "aws_vpc_endpoint_service" "nlb_endpoint_service" {
  acceptance_required        = false
  network_load_balancer_arns = [aws_lb.nlb_internal.arn]
}

resource "aws_security_group" "vpce_sg" {
  name        = "vpce_sg"
  description = "Allow inbound from anywhere or CloudFront"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# VPCE endpoint is not publicly accessible, so we need to create an Interface VPC Endpoint for CloudFront
resource "aws_vpc_endpoint" "cloudfront_vpce" {
  vpc_id            = module.vpc.vpc_id
  service_name      = aws_vpc_endpoint_service.nlb_endpoint_service.service_name
  vpc_endpoint_type = "Interface"
  subnet_ids        = module.vpc.public_subnets # Use public subnets for VPCE
  # CloudFront is a global service running outside your VPC, so it can’t directly access private ENIs inside your VPC
  # This is a valid workaround until getting a cert and setup a public ALB with HTTPS.
  security_group_ids = [aws_security_group.vpce_sg.id]
}