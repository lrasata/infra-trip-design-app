resource "aws_lb" "nlb_internal" {
  name               = "nlb-internal"
  internal           = true
  load_balancer_type = "network"
  subnets            = module.vpc.private_subnets
  security_groups    = [aws_security_group.nlb_sg.id]
}

resource "aws_lb_target_group" "nlb_tg_ecs" {
  name        = "ecs-target-group"
  port        = 8080
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id

  health_check {
    # path                = "/actuator/health" Ignored for NLB TCP protocol
    port                = "traffic-port"
    protocol            = "TCP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "nlb_listener" {
  load_balancer_arn = aws_lb.nlb_internal.arn
  port              = 8080
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb_tg_ecs.arn
  }
}

resource "aws_security_group" "nlb_sg" {
  name   = "nlb_sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.vpce_sg.id] # only allow traffic from VPC Endpoint SG
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

