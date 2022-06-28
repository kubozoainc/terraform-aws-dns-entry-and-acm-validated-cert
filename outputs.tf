output "zone_id" {
  description = "The hosted zone id for the subdomain that was created or used"
  value       = local.subdomain_zone_id
}

output "certificate_arn" {
  description = "ARN for the validated certificate"
  value       = aws_acm_certificate.cert.arn
}