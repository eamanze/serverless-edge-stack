output "website_url" {
  value       = "https://${var.domain_name}"
  description = "Public website URL."
}
output "bucket_name" {
  value       = aws_s3_bucket.site.id
  description = "Deployment target bucket."
}
output "cloudfront_distribution_id" {
  value       = aws_cloudfront_distribution.site.id
  description = "Distribution used for invalidations."
}
output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.site.domain_name
}

output "github_deploy_role_arn" {
  description = "Set this ARN as the GitHub Actions AWS_DEPLOY_ROLE_ARN variable."
  value       = aws_iam_role.github_deploy.arn
}
