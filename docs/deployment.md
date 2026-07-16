# Deployment guide

## Prerequisites

- An AWS account and an existing public Route 53 hosted zone
- Terraform 1.6+, AWS CLI v2, and authenticated AWS credentials
- A GitHub repository for this project

## 1. Provision the platform

```bash
cp infra/terraform.tfvars.example infra/terraform.tfvars
# Edit the domain and hosted zone values.
terraform -chdir=infra init
terraform -chdir=infra plan -out=tfplan
terraform -chdir=infra apply tfplan
```

CloudFront deployment and ACM validation can take several minutes. Save the outputs:

```bash
terraform -chdir=infra output
```

For team use, configure an S3 backend with DynamoDB locking (or HCP Terraform) before the first apply. Backend configuration is deliberately environment-specific and is not hard-coded in this demo.

## 2. First upload

The bucket is private, so upload content through the AWS CLI:

```bash
BUCKET=$(terraform -chdir=infra output -raw bucket_name)
DIST=$(terraform -chdir=infra output -raw cloudfront_distribution_id)
aws s3 sync site/ "s3://${BUCKET}/" --delete
aws cloudfront create-invalidation --distribution-id "$DIST" --paths "/*"
```

## 3. Configure continuous deployment

Create a GitHub OIDC provider and a least-privilege IAM role. Limit the trust policy `sub` claim to your repository and production environment. The role needs:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": "arn:aws:s3:::YOUR_BUCKET"
    },
    {
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"],
      "Resource": "arn:aws:s3:::YOUR_BUCKET/*"
    },
    {
      "Effect": "Allow",
      "Action": "cloudfront:CreateInvalidation",
      "Resource": "YOUR_DISTRIBUTION_ARN"
    }
  ]
}
```

In the GitHub `production` environment, add these non-secret variables:

| Variable | Terraform output/value |
|---|---|
| `AWS_DEPLOY_ROLE_ARN` | ARN of the OIDC deployment role |
| `AWS_REGION` | `aws_region` used by Terraform |
| `S3_BUCKET_NAME` | `bucket_name` output |
| `CLOUDFRONT_DISTRIBUTION_ID` | `cloudfront_distribution_id` output |

Protect the environment with required reviewers if desired. A push to `main` that changes `site/**` then deploys automatically.

## Rollback

1. Revert the failed commit and push to `main`; this is the preferred, auditable path.
2. For urgent recovery, restore the previous S3 object versions.
3. Invalidate the affected CloudFront paths.

## Destroy

Empty the versioned bucket (including old versions) before running `terraform destroy`. Destruction is intentionally not automated in CI.

