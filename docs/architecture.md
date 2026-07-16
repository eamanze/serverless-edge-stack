# Architecture

```text
Developer ──push──> GitHub Actions ──OIDC──> AWS IAM
                          │                    │
                          ├── s3 sync ─────────┤
                          └── invalidation ────┘

Visitor ──HTTPS──> Route 53 ──alias──> CloudFront ──signed request──> private S3
                                           │
                                      ACM certificate
```

## Request path

1. Route 53 publishes IPv4 and IPv6 alias records for the domain.
2. CloudFront terminates HTTPS using an ACM certificate issued in `us-east-1`, as required for CloudFront.
3. CloudFront returns a cached object when possible. Brotli and Gzip compression are enabled.
4. On a cache miss, CloudFront signs the S3 request with SigV4 through Origin Access Control (OAC).
5. The S3 bucket policy accepts reads only from this distribution. All public access remains blocked.

## Cache strategy

| Content | Browser header | CloudFront default TTL | Reason |
|---|---:|---:|---|
| HTML | 5 minutes | 5 minutes | Releases become visible quickly. |
| `/assets/*` | 1 year, immutable | 1 day | Static assets change rarely; use content hashes before production releases that modify them. |
| Errors | — | 1 minute | A corrected missing object recovers quickly. |

The pipeline invalidates `/` and HTML after deployment. Asset invalidations are intentionally avoided; for a larger site, filenames should contain a build hash so new releases create new cache keys.

## Security controls

- S3 Block Public Access enabled at the bucket.
- Bucket-owner-enforced object ownership; ACLs are disabled.
- Server-side AES-256 encryption and object versioning.
- CloudFront is the only principal permitted to read objects, scoped by distribution ARN.
- HTTP redirects to HTTPS; minimum viewer protocol is TLS 1.2 (2021 policy).
- GitHub Actions uses short-lived OIDC credentials rather than long-lived AWS keys.
- The workflow requests only `contents: read` and `id-token: write` permissions.

## Availability and recovery

CloudFront distributes copies across edge locations and shields the regional origin. S3 provides durable object storage. Previous object versions remain available for 30 days, enabling rollback by restoring a version or redeploying a known Git commit.

