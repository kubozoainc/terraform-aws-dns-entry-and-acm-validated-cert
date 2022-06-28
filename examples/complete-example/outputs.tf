output "zone_id" {
  description = "The hosted zone id for the subdomain that was created or used"
  value       = module.dns_with_cert.zone_id
}

output "certificate_arn" {
  description = "ARN for the validated certificate"
  value       = module.dns_with_cert.certificate_arn
}