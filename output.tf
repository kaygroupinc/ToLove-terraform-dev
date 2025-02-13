output "nlb_eip_a_public_ip" {
  description = "The public IP of NLB Elastic IP A"
  value       = aws_eip.nlb_eip_a.public_ip
}

output "nlb_eip_b_public_ip" {
  description = "The public IP of NLB Elastic IP B"
  value       = aws_eip.nlb_eip_b.public_ip
}

output "nlb_dns_name" {
  description = "The DNS name of the Network Load Balancer"
  value       = aws_lb.nlb.dns_name
}