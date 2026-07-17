# AWS serverless-edge-stack

A portfolio-grade static website delivered through a secure, globally cached AWS architecture. The repository demonstrates infrastructure as code, DNS and TLS configuration, cache design, least-privilege deployment, CI validation, and operational documentation.

## What this demonstrates

- **S3:** private, encrypted, versioned origin with all public access blocked
- **CloudFront:** Origin Access Control, HTTPS redirect, compression, IPv6, custom errors, and tiered caching
- **Route 53:** A and AAAA alias records to CloudFront
- **ACM:** DNS-validated certificate in `us-east-1`
- **Caching:** short-lived HTML, long-lived static assets, and targeted invalidations
- **Deployment:** keyless GitHub Actions authentication using AWS OIDC
- **Documentation:** architecture decisions, deployment guide, rollback, troubleshooting, and cost posture

## Architecture

```text
Visitor → Route 53 → CloudFront + ACM → private S3 bucket
                         ↑
GitHub Actions → AWS OIDC role → S3 sync + cache invalidation
```

CloudFront—not the S3 website endpoint—is the public entry point. This permits a fully private bucket while retaining custom-domain HTTPS and global caching. See [the detailed architecture](docs/architecture.md).

## Repository layout

```text
site/                 Static HTML, CSS, and JavaScript
infra/                Terraform AWS infrastructure
.github/workflows/    Validation and deployment pipelines
scripts/              Local/CI validation
docs/                 Architecture, deployment, and operations runbooks
```

## Quick start

Preview locally:

```bash
make preview
# Open http://localhost:8080
```

Provision AWS infrastructure:

```bash
cp infra/terraform.tfvars.example infra/terraform.tfvars
# Set a domain in a Route 53 hosted zone you control.
terraform -chdir=infra init
terraform -chdir=infra plan
terraform -chdir=infra apply
```

Then follow the [deployment guide](docs/deployment.md) to upload the first release and configure GitHub OIDC.

## Engineering notes

This implementation intentionally models infrastructure and website delivery separately. Terraform owns long-lived AWS resources; the deployment workflow owns site objects. That keeps content releases fast and avoids a Terraform plan for every CSS change.

Before presenting the project, replace the placeholder GitHub link in `site/index.html`, update the visible profile copy, and capture a live URL in this README.

## Documentation

- [Architecture and security](docs/architecture.md)
- [Provisioning and deployment](docs/deployment.md)
- [GitHub Actions OIDC setup](docs/github-oidc.md)
- [Operations and troubleshooting](docs/operations.md)

## License

MIT
