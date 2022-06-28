#---------------------- Route 53 Entry for project ---------------#

# To create a domain in Route 53: 
# a) We have to create the domain name (aws_route53_zone) 
# b) as well as the NS record (aws_route53_record) for the domain in the parent domain

locals {

  # Fetch the parent_domain from the subdomain
  parent_domain     = regex("([0-9A-Za-z_-])\\.(.*)", var.subdomain)[1]
  subdomain_zone_id = data.aws_route53_zone.subdomain.zone_id
}

# what is our existing parent domain public zone. Look it up
data "aws_route53_zone" "parent_domain" {
  count = var.create_subdomain ? 1 : 0
  name  = local.parent_domain
}

# Create subdomain record if we have been asked to do so.
resource "aws_route53_zone" "subdomain" {
  count = var.create_subdomain ? 1 : 0

  name    = var.subdomain
  comment = var.subdomain_zone_description == null ? "" : var.subdomain_zone_description
}

# Create nameservers for the subdomain record in the parent domain
resource "aws_route53_record" "subdomain_ns" {
  count   = var.create_subdomain ? 1 : 0
  zone_id = var.parent_zone_id == "" ? data.aws_route53_zone.parent_domain[0].zone_id : var.parent_zone_id

  name = var.subdomain
  type = "NS"
  ttl  = var.subdomain_ns_ttl

  records = aws_route53_zone.subdomain[0].name_servers
}

# Fetch the subdomain zone_id from AWS.
data "aws_route53_zone" "subdomain" {
  name = var.subdomain
  depends_on = [
    aws_route53_zone.subdomain
  ]
}

#---------------------- ACM Validation ---------------#

# The following needs to happen:
# 1) Create the ACM certificate and fetch the DNS record from the ACM certificate for validation
# 2) Add the DNS entry for the subdomain
# 3) Request validation from the ACM certificate

# 1. First, create the certificate
resource "aws_acm_certificate" "cert" {

  domain_name = var.subdomain # The subdomain for the project

  subject_alternative_names = var.subject_alternative_names # Add SAN for validation
  validation_method         = "DNS"

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }

  # Ensure that we have somehow retrieved a valid subdomain hosted zone ID before creating the certificate.
  # Otherwise it is most likely going to fail at the validation phase.
  depends_on = [
    data.aws_route53_zone.subdomain
  ]

}

# 2. Validate the domain
resource "aws_route53_record" "validate_cert_domain" {

  # Loop through all records in the SAN array to ensure we validate all the domains
  for_each = {
    for entry in aws_acm_certificate.cert.domain_validation_options : entry.domain_name => {
      name   = entry.resource_record_name
      record = entry.resource_record_value
      type   = entry.resource_record_type
    }
  }

  zone_id = local.subdomain_zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = var.subdomain_ns_ttl

  allow_overwrite = var.allow_dns_validation_record_overwrite

}

#3. Ok, domain has been validated. Validate the certificate now. 
resource "aws_acm_certificate_validation" "validate_cert" {
  certificate_arn = aws_acm_certificate.cert.arn

  validation_record_fqdns = [for record in aws_route53_record.validate_cert_domain : record.fqdn]
}
