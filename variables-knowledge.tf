variable "env" {
  description = "Deployment environment (e.g., prod, stage)"
  type        = string
  default     = "prod"
}

variable "knowledge_bucket_name" {
  description = "S3 bucket name used to store Knowledge Base documents"
  type        = string
  default     = "autonomia-knowledge-docs"
}

variable "knowledge_bucket_enable_public" {
  description = "If true, enables public read for objects (temporary approach until CloudFront or signed URLs)"
  type        = bool
  default     = false
}

variable "portal_allowed_origins" {
  description = "Origins allowed to GET from the knowledge bucket when CORS is used"
  type        = list(string)
  default     = [
    "https://portal.autonomia.site",
    "http://localhost:3000",
    "https://auto.autonomia.site"
  ]
}
