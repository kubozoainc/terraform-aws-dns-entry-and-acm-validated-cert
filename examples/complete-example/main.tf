locals {
    project_domain = "myproject.mydomain.com"
}

module "dns_with_cert" {
  source = "../../"

  create_subdomain           = true
  subdomain                  = local.project_domain
  subdomain_zone_description = "Subdomain for Project X Development"
  subdomain_ns_ttl           = "30"

  parent_zone_id = ""

  subject_alternative_names = [
    "*.${local.project_domain}",
    "notifications.${local.project_domain}",
    "anything-else.${local.project_domain}"
  ]
  allow_dns_validation_record_overwrite = true

  tags = {
    Name        = "${local.project_domain}"
    Project     = "myproject"
    Cost-Centre = "KB-123456"
  }

}