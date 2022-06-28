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

## Input Variables

* `subdomain` *

    Mandatory. Subdomain for the project e.g. myproject.mysub.domain.com.

* `create_subdomain`

    Whether or not to create the subdomain for the project. Default: `true`

* `subdomain_zone_description`

    Description field for the hosted zone entry. Default: `Managed by Terraform`

* `parent_zone_id`

    Route53 Zone ID of the parent domain. Default: `""`

* `subdomain_ns_ttl`

    Time to live (TTL) for the DNS record. Default: `"60"`

* `subject_alternative_names`

    A list of the SAN (Subject Alternative Name) domain names that should be included as part of the certificate. Default: `null`

* `allow_dns_validation_record_overwrite`

    Whether or not to allow the overwriting of the Route53 CNAME DNS records that are used to validate the certificate. Default: `true`

* `tags`

    Tags for the certificate. Default: `null`


***

## Outputs

* `zone_id`

    The hosted zone id for the subdomain that was created or used

* `certificate_arn`

    Amazon Resource Name (ARN) for the validated certificate

***

## Author

<a href="https://github.com/kubozoainc" target="_blank">Kubozoa</a> and its awesome talented team members. 

***

## License

See LICENSE for more information


***

## Contact Kubozoa

<a href="https://www.kubozoa.com" target="_blank"><img src="https://assets.kubozoa.com/logo/kubozoa-logo-nr-color.png" width="60" alt="Kubozoa"/></a>

You can open an issue for this project or you can also say hi at hello@kubozoa.com.
