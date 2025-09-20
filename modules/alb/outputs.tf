output "alb_dns_name" {
  description = "The DNS name of the ALB."
  value       = aws_lb.main.dns_name
}

output "alb_security_group_id" {
  description = "The ID of the ALB's security group."
  value       = aws_security_group.alb_sg.id
}

output "target_group_a_arn" {
  description = "The ARN of the nginx-a target group."
  value       = aws_lb_target_group.nginx_a.arn
}

output "target_group_b_arn" {
  description = "The ARN of the nginx-b target group."
  value       = aws_lb_target_group.nginx_b.arn
}

