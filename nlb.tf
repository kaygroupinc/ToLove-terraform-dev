##############################
# Allocate Elastic IPs       #
##############################
resource "aws_eip" "nlb_eip_a" {
  tags = {
    Name = "nlb-eip-a"
  }
}

resource "aws_eip" "nlb_eip_b" {
  tags = {
    Name = "nlb-eip-b"
  }
}

##############################
# Create the Network Load Balancer (NLB)
##############################
resource "aws_lb" "nlb" {
  name               = "my-nlb"
  internal           = false
  load_balancer_type = "network"

  # Use subnet mappings to attach the Elastic IPs to specific subnets
  subnet_mapping {
    subnet_id     = aws_subnet.public_subnet_a.id
    allocation_id = aws_eip.nlb_eip_a.id
  }

  subnet_mapping {
    subnet_id     = aws_subnet.public_subnet_b.id
    allocation_id = aws_eip.nlb_eip_b.id
  }

  tags = {
    Name = "my-nlb"
  }
}

##############################
# Create the Target Group      #
##############################
resource "aws_lb_target_group" "nlb_target_group" {
  name        = "my-nlb-targets"
  port        = 80
  protocol    = "TCP"
  target_type = "ip"        # For Fargate, use "ip"
  vpc_id      = aws_vpc.tolove_vpc.id

  health_check {
    protocol = "TCP"
    port     = "80"
  }

  tags = {
    Name = "my-nlb-targets"
  }
}

##############################
# Create the Listener        #
##############################
resource "aws_lb_listener" "nlb_listener" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb_target_group.arn
  }
}

##############################
# Domain                     #
##############################

data "aws_route53_zone" "primary" {
  name         = var.custom_domain
  private_zone = false
}

resource "aws_route53_record" "nlb_alias" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "dev"  // e.g., "api.example.com"
  type    = "A"

  alias {
    name                   = aws_lb.nlb.dns_name
    zone_id                = aws_lb.nlb.zone_id
    evaluate_target_health = true
  }
}
