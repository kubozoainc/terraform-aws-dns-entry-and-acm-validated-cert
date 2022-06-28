#---------------------- Variables For DNS Entry ---------------#

variable "subdomain" {
  type        = string
  default     = ""
  description = "Subdomain for the project"
}

variable "create_subdomain" {
  type        = bool
  default     = true
  description = "Whether or not to create the subdomain for the project"
}

variable "subdomain_zone_description" {
  type        = string
  default     = "Managed by Terraform"
  description = "Description field for the hosted zone entry. Defaults to Managed by Terraform"
}

variable "parent_zone_id" {
  type        = string
  description = "Route53 Zone ID of the parent domain"
  default     = ""
}

variable "subdomain_ns_ttl" {
  type        = string
  default     = "60"
  description = "Time to live (TTL) for the DNS record."
}

#---------------------- Variables For ACM ---------------#

variable "subject_alternative_names" {
  type        = list(string)
  description = "A list of the SAN (Subject Alternative Name) domain names that should be included as part of the certificate"
}

variable "allow_dns_validation_record_overwrite" {
  type        = bool
  default     = true
  description = "Whether or not to allow the overwriting of the Route53 CNAME DNS records that are used to validate the certificate."
}

variable "tags" {
  type        = map(string)
  description = "Tags for the certificate"
}