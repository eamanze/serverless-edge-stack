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

Follow the [GitHub Actions OIDC setup guide](github-oidc.md). The Terraform
configuration creates the provider, branch-scoped trust policy, deployment
role, and least-privilege permissions. The trusted subject is limited to the
repository's main branch.

## Rollback

1. Revert the failed commit and push to `main`; this is the preferred, auditable path.
2. For urgent recovery, restore the previous S3 object versions.
3. Invalidate the affected CloudFront paths.

## Destroy

Empty the versioned bucket (including old versions) before running `terraform destroy`. Destruction is intentionally not automated in CI.
