output "alb_dns_name" {
  description = "The DNS name of the internal ALB"
  value       = aws_lb.internal.dns_name
}

output "alb_zone_id" {
  description = "The canonical hosted zone ID of the internal ALB"
  value       = aws_lb.internal.zone_id
}

output "alb_security_group_id" {
  description = "The ID of the security group for the internal ALB"
  value       = aws_security_group.alb.id
}

output "kong_target_group_arn" {
  description = "The ARN of the Kong target group"
  value       = aws_lb_target_group.kong.arn
}

output "konga_target_group_arn" {
  description = "The ARN of the Konga target group"
  value       = aws_lb_target_group.konga.arn
}

output "http_listener_arn" {
  description = "The ARN of the HTTP listener"
  value       = aws_lb_listener.http.arn
}
