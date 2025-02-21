##############################
# Allocate Elastic IPs       #
##############################
resource "aws_eip" "nlb_eip_a_dev" {
  tags = {
    Name = "nlb-eip-a-dev"
  }
}

resource "aws_eip" "nlb_eip_b_dev" {
  tags = {
    Name = "nlb-eip-b-dev"
  }
}

# resource "aws_eip" "nlb_eip_c_dev" {
#   tags = {
#     Name = "nlb-eip-c-dev"
#   }
# }

##############################
# Create the Network Load Balancer (NLB)
##############################
resource "aws_lb" "nlb_dev" {
  name               = "tolove-events-nlb-dev"
  internal           = false
  load_balancer_type = "network"

  # Use subnet mappings to attach the Elastic IPs to specific subnets
  subnet_mapping {
    subnet_id     = module.vpc.public_subnets[0]
    allocation_id = aws_eip.nlb_eip_a_dev.id
  }

  subnet_mapping {
    subnet_id     = module.vpc.public_subnets[1]
    allocation_id = aws_eip.nlb_eip_b_dev.id
  }

  # subnet_mapping {
  #   subnet_id     = module.vpc.public_subnets[2]
  #   allocation_id = aws_eip.nlb_eip_c_dev.id
  # }

  tags = {
    Name = "tolove-events-nlb-dev"
  }
}

##############################
# Create the Target Group      #
##############################
resource "aws_lb_target_group" "nlb_target_group_dev" {
  name        = "tolove-events-nlb-targets-dev"
  port        = 80
  protocol    = "TCP"
  target_type = "ip"        # For Fargate, use "ip"
  vpc_id      = module.vpc.vpc_id

  health_check {
    protocol = "TCP"
    port     = "80"
  }

  tags = {
    Name = "tolove-events-nlb-targets-dev"
  }
}

##############################
# Create the Listener        #
##############################
resource "aws_lb_listener" "nlb_listener_dev" {
  load_balancer_arn = aws_lb.nlb_dev.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb_target_group_dev.arn
  }
}

resource "aws_acm_certificate" "cert_dev" {
  domain_name       = "kaytolove.com"
  validation_method = "DNS"
}

resource "aws_lb_listener" "nlb_listener_https_dev" {
  load_balancer_arn = aws_lb.nlb_dev.arn
  port              = "443"
  protocol          = "TLS"

  ssl_policy      = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn = aws_acm_certificate.cert_dev.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb_target_group_dev.arn
  }
}


##############################
# Domain                     #
##############################

data "aws_route53_zone" "primary_dev" {
  name         = var.custom_domain
  private_zone = false
}

resource "aws_route53_record" "nlb_alias_dev" {
  zone_id = data.aws_route53_zone.primary_dev.zone_id
  name    = "dev"  // e.g., "api.example.com"
  type    = "A"

  alias {
    name                   = aws_lb.nlb_dev.dns_name
    zone_id                = aws_lb.nlb_dev.zone_id
    evaluate_target_health = true
  }
}
