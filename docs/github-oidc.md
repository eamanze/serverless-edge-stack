# GitHub Actions OIDC setup

This project uses GitHub OIDC to obtain short-lived AWS credentials. No AWS
access key or secret access key is stored in GitHub.

## 1. Set the repository identity

Copy the example variables file if you have not already done so:

    cp infra/terraform.tfvars.example infra/terraform.tfvars

Set these values to the exact, case-sensitive GitHub owner and repository:

    github_owner      = "YOUR_GITHUB_USERNAME_OR_ORG"
    github_repository = "serverless-edge-stack"

The Terraform trust policy will accept only this subject:

    repo:YOUR_GITHUB_USERNAME_OR_ORG/serverless-edge-stack:ref:refs/heads/main

The workflow does not declare a GitHub environment. That is important because
an environment would replace the branch-based subject with an
environment-based subject.

## 2. Check for an existing AWS provider

AWS permits only one IAM OIDC provider for the GitHub issuer in an account.
Check whether one already exists:

    aws iam list-open-id-connect-providers

If the output contains token.actions.githubusercontent.com, import it:

    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    terraform -chdir=infra import aws_iam_openid_connect_provider.github \
      "arn:aws:iam::${ACCOUNT_ID}:oidc-provider/token.actions.githubusercontent.com"

If no GitHub provider exists, do not run the import. Terraform will create it.

## 3. Provision the provider and role

Run:

    terraform -chdir=infra fmt -recursive
    terraform -chdir=infra init
    terraform -chdir=infra validate
    terraform -chdir=infra plan
    terraform -chdir=infra apply

Terraform configures:

- Issuer: https://token.actions.githubusercontent.com
- Audience: sts.amazonaws.com
- Subject: the exact main-branch value shown above
- Role permissions: S3 deployment and CloudFront cache invalidation only

Get the deployment role ARN:

    terraform -chdir=infra output -raw github_deploy_role_arn

## 4. Add GitHub Actions variables

Open GitHub repository → Settings → Secrets and variables → Actions →
Variables, then create:

| Variable | Value |
|---|---|
| AWS_DEPLOY_ROLE_ARN | Output of github_deploy_role_arn |
| AWS_REGION | Same value as aws_region in Terraform |
| S3_BUCKET_NAME | Terraform bucket_name output |
| CLOUDFRONT_DISTRIBUTION_ID | Terraform cloudfront_distribution_id output |

These values are identifiers and can be repository variables. Do not create
AWS_ACCESS_KEY_ID or AWS_SECRET_ACCESS_KEY secrets.

## 5. Verify the workflow

The workflow must contain:

    permissions:
      contents: read
      id-token: write

Push a change under site/ to main, or run Deploy website manually while
viewing the main branch. GitHub requests an OIDC token, AWS checks its audience
and subject, and STS returns short-lived role credentials.

## Troubleshooting

If STS reports Not authorized to perform sts:AssumeRoleWithWebIdentity:

1. Confirm the workflow run is from main.
2. Confirm github_owner and github_repository match GitHub exactly.
3. Confirm AWS_DEPLOY_ROLE_ARN is the role ARN output by Terraform.
4. Confirm the provider and role are in the same AWS account.
5. Inspect the role trust policy and compare its subject with the expected
   value above.

