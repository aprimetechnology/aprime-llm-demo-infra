output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = module.text_generation_inference.alb_dns_name
}

output "ui_url" {
  description = "The UI url if a domain was given"
  value       = module.text_generation_inference.ui_url
}
