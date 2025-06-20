# Security Policy

## Supported Versions

| Version | Supported          | Security Fixes Only |
| ------- | ------------------ | ------------------- |
| Main    | ✔️ Current release | ✔️ Always secure    |

## Reporting a Vulnerability

If you discover a security issue in this infrastructure code, please report it by emailing **[disaenz2@gmail.com](mailto:disaenz2@gmail.com)**. Include:

* A description of the vulnerability
* Steps to reproduce or proof-of-concept
* Suggested mitigation or fix

You will receive an acknowledgment within 48 hours, and disclosures will be coordinated to avoid exposing live resources before a fix is in place.

## Security Practices

* **Least Privilege:** All AWS IAM policies are scoped to minimal permissions required.
* **Secret Management:** Pipeline credentials use GitHub Actions secrets with least-privilege access.
* **Infrastructure Scanning:** Terraform plans are validated in CI, and drift detection prevents unauthorized changes.
* **Encryption:** AWS resources use default encryption at rest and TLS in transit where available.

---

© 2025 Daniel Saenz
