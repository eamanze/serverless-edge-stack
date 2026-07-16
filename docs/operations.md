# Operations runbook

## Verification

```bash
curl -I https://YOUR_DOMAIN/
curl -I https://YOUR_DOMAIN/assets/styles.css
```

Confirm `server: CloudFront`, a valid certificate, `x-cache` changing from `Miss from cloudfront` to `Hit from cloudfront`, and the expected `cache-control` headers.

## Common failures

| Symptom | Likely cause | Action |
|---|---|---|
| ACM stays pending | DNS validation record is absent or delegated elsewhere | Confirm the domain uses the selected Route 53 zone. |
| CloudFront returns 404 | Object was not uploaded or key casing differs | Inspect `aws s3 ls s3://BUCKET --recursive`, then sync again. |
| Deployment gets AccessDenied | OIDC trust `sub` or IAM resource ARN is too narrow/incorrect | Compare the GitHub environment and repository name with the role trust policy. |
| Old page persists | Browser/edge cache has not expired | Check headers, then create a targeted invalidation. |

## Observability extensions

For a production workload, add CloudFront standard logs to a dedicated log bucket, CloudWatch alarms for elevated 4xx/5xx rates, AWS WAF managed rules, and a cost budget. They are omitted here to keep the baseline low-cost and avoid storing visitor logs without an explicit retention policy.

## Cost posture

Primary charges are Route 53 hosted-zone/query fees, CloudFront requests and transfer, S3 storage/requests, and ACM public-certificate usage where applicable. `PriceClass_100` limits the default edge footprint. Check current AWS pricing and set a budget before deployment.

