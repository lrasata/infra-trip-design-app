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
# To achieve this we expose load balancer as a VPC Endpoint Service (PrivateLink). This way, traffic stays within AWS network
# Lower latency, more reliable, reduce charges for data transfer
resource "aws_vpc_endpoint_service" "nlb_endpoint_service" {
  acceptance_required        = false
  network_load_balancer_arns = [aws_lb.nlb_internal.arn]
}
