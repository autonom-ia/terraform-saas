variable "frontend_bucket_name" {
  description = "Name of the S3 bucket for the frontend"
  type        = string
  default     = "autonomia-frontend-prod"
}

variable "frontend_domains" {
  description = "Aliases for the CloudFront distribution"
  type        = list(string)
  default = [
    "portal.autonomia.site",
    "empresta.autonomia.site",
    "copar.autonomia.site"
  ]
}

variable "certificate_arn" {
  description = "Full ACM certificate ARN in us-east-1 for CloudFront"
  type        = string
  default     = ""
}

variable "acm_domain_name" {
  description = "Domain name to match when looking up the ACM certificate in us-east-1 (e.g., \"*.autonomia.site\" or \"autonomia.site\")."
  type        = string
  default     = "*.autonomia.site"
}

# Deprecated: kept for backward compatibility; no longer used to construct ARNs
variable "certificate_id" {
  description = "ACM certificate ID to construct ARN if certificate_arn is not provided"
  type        = string
  default     = "cee74474-da0c-4aba-b9f7-3759e4eddd7e"
}

# Deprecated: kept for backward compatibility; no longer used to construct ARNs
variable "aws_account_id" {
  description = "AWS Account ID used to build the certificate ARN when only the certificate_id is provided"
  type        = string
  default     = ""
}
