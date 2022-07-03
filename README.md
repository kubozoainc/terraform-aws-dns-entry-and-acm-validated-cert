# Terraform AWS Route53 Entry and ACM Validated Cert

## Project name: aws-dns-entry-and-acm-validated-cert

## Description

A Terraform module that does the following:

1. Create a DNS entry for your project.
    * This is optional. You can also use one that already exists.

2. Creates an ACM (AWS Certificate Manager) certificate
    * With the specified domain and/or related SANs (Subject Alternate Name).

3. Validates the certificate using Route53 DNS 
    * DNS CNAME based verification is generally the recommended method compared to email.

4. Outputs the Zone ID for the newly created DNS entry, and the certificate ARN to further your call flows.

## Use case

Most, if not all projects deployed on the cloud's public domain will require some form of secure entrypoint into the system. 

For instance, whenever you create a public load balancer or an EC2 instance in a public subnet or an S3 bucket to host a static website using CloudFront distribution, instead of accessing your service using http://some-alb-1234567890.us-east-1.alb.amazonaws.com, it is a lot more fun accessing it using http://myproject.mydomain.com. This module creates a DNS entry in Route53 for your project if you dont already have one. 

Now, what about https? This module also generates an AWS ACM resource by validating the domain name via Route53 and provides you with the resulting Certificate's unique ARN (Amazon Resource Name) which you can then use for your loadbalancer or other  resources. 

This way, you can access your service using **https**://myproject.myservice.com while this module takes care most of the plumbing work for you.

Happy Terraforming!


***

## Usage example 1 - Create project subdomain entry and ACM cert

```
module "dns_with_cert" {
    source = "kubozoainc/dns-entry-and-acm-validated-cert/aws"

    create_subdomain   = true
    subdomain          = "myproject.mydomain.com"

    subject_alternative_names = [
        "*.myproject.mydomain.com",
        "notifications.myproject.mydomain.com",
        "anything-else.myproject.mydomain.com"
    ]

    tags = {
        Name        = "myproject.mydomain.com"
        Project     = "myproject"
        Cost-Centre = "KB-123456"
    }

}
```

## Usage example 2 - Create project subdomain entry with known parent_zone_id and ACM cert

```
# I already have the parent zone id. Let me look it up. 
data "aws_route53_zone" "parent" {
  name = "mydomain.com"
}

module "dns_with_cert" {
    source = "kubozoainc/dns-entry-and-acm-validated-cert/aws"

    create_subdomain   = true
    subdomain          = "myproject.mydomain.com"
    parent_zone_id     = data.parent.zone_id

    subject_alternative_names = [
        "*.myproject.mydomain.com",
        "notifications.myproject.mydomain.com",
        "anything-else.myproject.mydomain.com"
    ]

    tags = {
        Name        = "myproject.mydomain.com"
        Project     = "myproject"
        Cost-Centre = "KB-123456"
    }

}
```

## Usage example 3 - Create ACM cert for a project where the subdomain already exists in Route53.

```
module "dns_with_cert" {
    source = "kubozoainc/dns-entry-and-acm-validated-cert/aws"

    create_subdomain   = false
    subdomain          = "myproject.mydomain.com"

    subject_alternative_names = [
        "*.myproject.mydomain.com",
        "notifications.myproject.mydomain.com",
        "anything-else.myproject.mydomain.com"
    ]

    tags = {
        Name        = "myproject.mydomain.com"
        Project     = "myproject"
        Cost-Centre = "KB-123456"
    }

}
```

**Considerations:**

* if `create_subdomain = true`, the parent domain must exist in Route 53 and is resolvable or fetching the zone_id will fail. The module will fetch the appropriate zone_id for you.
* if you already have the parent domain's zone_id, you can specify it in the parent_zone_id parameter. See the variables file for more details.
* if `create_subdomain = false`, the project domain must exist in Route 53. The module will fetch the project zone_id and use it for the DNS validation. 

***

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.13.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.13.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate_validation.validate_cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_route53_record.subdomain_ns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.validate_cert_domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_zone.subdomain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_route53_zone.parent_domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [aws_route53_zone.subdomain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_dns_validation_record_overwrite"></a> [allow\_dns\_validation\_record\_overwrite](#input\_allow\_dns\_validation\_record\_overwrite) | Whether or not to allow the overwriting of the Route53 CNAME DNS records that are used to validate the certificate. | `bool` | `true` | no |
| <a name="input_create_subdomain"></a> [create\_subdomain](#input\_create\_subdomain) | Whether or not to create the subdomain for the project | `bool` | `true` | no |
| <a name="input_parent_zone_id"></a> [parent\_zone\_id](#input\_parent\_zone\_id) | Route53 Zone ID of the parent domain | `string` | `""` | no |
| <a name="input_subdomain"></a> [subdomain](#input\_subdomain) | Subdomain for the project | `string` | n/a | yes |
| <a name="input_subdomain_ns_ttl"></a> [subdomain\_ns\_ttl](#input\_subdomain\_ns\_ttl) | Time to live (TTL) for the DNS record. | `string` | `"60"` | no |
| <a name="input_subdomain_zone_description"></a> [subdomain\_zone\_description](#input\_subdomain\_zone\_description) | Description field for the hosted zone entry. Defaults to Managed by Terraform | `string` | `"Managed by Terraform"` | no |
| <a name="input_subject_alternative_names"></a> [subject\_alternative\_names](#input\_subject\_alternative\_names) | A list of the SAN (Subject Alternative Name) domain names that should be included as part of the certificate | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags for the certificate | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_certificate_arn"></a> [certificate\_arn](#output\_certificate\_arn) | ARN for the validated certificate |
| <a name="output_zone_id"></a> [zone\_id](#output\_zone\_id) | The hosted zone id for the subdomain that was created or used |


***

## Acknowledgements

* https://github.com/terraform-docs/terraform-docs

## Author

<a href="https://github.com/kubozoainc" target="_blank">Kubozoa</a> and its awesome talented team members. 

## License

See LICENSE for more information

## Contact Kubozoa

<a href="https://www.kubozoa.com" target="_blank"><img src="https://assets.kubozoa.com/logo/kubozoa-logo-nr-color.png" width="60" alt="Kubozoa"/></a>

You can open an issue for this project or you can also say hi at hello@kubozoa.com.
