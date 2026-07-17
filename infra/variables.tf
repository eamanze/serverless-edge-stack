variable "aws_region" {
  description = "Region for the S3 origin."
  type        = string
  default     = "eu-west-1"
}
variable "domain_name" {
  description = "Fully qualified domain for the website (for example, portfolio.example.com)."
  type        = string
}
variable "hosted_zone_name" {
  description = "Existing public Route 53 zone (for example, example.com)."
  type        = string
}
variable "project_name" {
  description = "Resource naming prefix."
  type        = string
  default     = "cloud-portfolio"
}
variable "price_class" {
  description = "CloudFront edge footprint/cost tier."
  type        = string
  default     = "PriceClass_100"
}
variable "enable_versioning" {
  description = "Keep previous S3 object versions for recovery."
  type        = bool
  default     = true
}
variable "force_destroy_bucket" {
  description = "Delete all object versions when destroying the S3 bucket."
  type        = bool
  default     = true
}
variable "github_owner" {
  description = "GitHub user or organization that owns the deployment repository."
  type        = string
}
variable "github_repository" {
  description = "GitHub repository name allowed to deploy from its main branch."
  type        = string
}
