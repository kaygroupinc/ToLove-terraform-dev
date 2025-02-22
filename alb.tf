##############################
# Create a Security Group for the ALB
##############################
resource "aws_security_group" "alb_sg_dev" {
  name        = "alb-sg-dev"
  description = "Security group for the ALB"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

##############################
# Create the Application Load Balancer (ALB)
##############################
resource "aws_lb" "alb_dev" {
  name               = "tolove-events-alb-dev"
  internal           = false
  load_balancer_type = "application"
  subnets            = module.vpc.public_subnets
  security_groups    = [aws_security_group.alb_sg_dev.id]

  tags = {
    Name = "tolove-events-alb-dev"
  }
}

##############################
# Create the Target Group for the ALB
##############################
resource "aws_lb_target_group" "alb_target_group_dev" {
  name        = "tolove-events-alb-targets-dev"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"        # For Fargate, use "ip"
  vpc_id      = module.vpc.vpc_id

  health_check {
    protocol = "HTTP"
    path     = "/"         # Customize as needed for your app
    port     = "80"
  }

  tags = {
    Name = "tolove-events-alb-targets-dev"
  }
}

##############################
# Create the HTTPS Listener for the ALB
##############################
resource "aws_lb_listener" "alb_listener_https_dev" {
  load_balancer_arn = aws_lb.alb_dev.arn
  port              = "443"
  protocol          = "HTTPS"

  ssl_policy      = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn = "arn:aws:acm:eu-north-1:225989351056:certificate/1945032b-8a40-4100-bb52-e8607b18d0ec"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group_dev.arn
  }
}

##############################
# (Optional) Create an HTTP Listener to Redirect to HTTPS
##############################
resource "aws_lb_listener" "alb_listener_http_dev" {
  load_balancer_arn = aws_lb.alb_dev.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      protocol    = "HTTPS"
      port        = "443"
      status_code = "HTTP_301"
    }
  }
}

##############################
# Domain Alias Record in Route 53
##############################
data "aws_route53_zone" "primary_dev" {
  name         = var.custom_domain
  private_zone = false
}

resource "aws_route53_record" "alb_alias_dev" {
  zone_id = data.aws_route53_zone.primary_dev.zone_id
  name    = var.custom_domain  # e.g., "example.com"
  type    = "A"

  alias {
    name                   = aws_lb.alb_dev.dns_name
    zone_id                = aws_lb.alb_dev.zone_id
    evaluate_target_health = true
  }
}
