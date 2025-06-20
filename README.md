# AWS Infrastructure as Code (IaC) for Portfolio

This repository contains all the Terraform configurations required to provision and manage the AWS infrastructure for my personal portfolio site. Everything—from the S3 static site bucket to CloudFront CDN, origin access, and Route 53 DNS records—is (more to come) defined here as code and deployed via a CI/CD pipeline.

---

## 🚀 Overview

* **Language & Tools**: Terraform (HCL), AWS Provider
* **Services**:

  * **S3**: Private bucket for hosting static assets
  * **CloudFront**: CDN distribution with Origin Access Identity
  * **Route 53**: DNS zone and alias records for custom domain
* **Pipeline**: Fully automated GitHub Actions workflow for `terraform init`, `plan`, and `apply` on merges to `main`.

---

## 🔧 Prerequisites

1. **Terraform** v1.5+ installed locally.
2. **AWS CLI** configured with an IAM principal having:

   * S3, CloudFront, Route 53 permissions (least-privilege applied)
   * `acm:ListCertificates` in us-east-1
3. **GitHub repository secrets** set:

   * `AWS_ACCESS_KEY_ID`
   * `AWS_SECRET_ACCESS_KEY`
   * `AWS_REGION` 
   * `BUCKET_NAME` 
   * `DOMAIN_NAME` 

---

## ⚙️ Getting Started (Local)

1. **Clone the repo**

   ```bash
   git clone https://github.com/disaenz/aws-iac.git
   cd aws-iac
   ```

2. **Configure backend** (if using remote state, update `backend.tf`).

3. **Initialize Terraform**

   ```bash
   terraform init
   ```

4. **Review plan**

   ```bash
   terraform plan -out=tfplan
   ```

5. **Apply changes**

   ```bash
   terraform apply tfplan
   ```

---

## 🔄 CI/CD Pipeline

On push to `main`, GitHub Actions will:

1. `terraform init` with configured backend.
2. Automatically import existing resources (if detected).
3. `terraform plan` and upload plan for review.
4. On merge, `terraform apply` auto-approves.

All pipeline logs and status checks must pass before merging.

---

## 📘 Variables

| Name          | Description                       | Default      |
| ------------- | --------------------------------- | ------------ |
| `bucket_name` | S3 bucket to host the static site | **Required** |
| `domain_name` | Custom domain for Route 53        | **Required** |
| `aws_region`  | AWS region for resources          | `us-east-2`  |

Check `variables.tf` for full list.

---

## 📦 Outputs

* `cloudfront_domain_name`: The generated CloudFront distribution domain.
* `website_endpoint`: The S3 static website endpoint (useful for testing).
* `route53_zone_id`: The hosted zone ID for DNS.

---

## ⚖️ License & Attribution

This code is open source under the MIT License. Feel free to fork and adapt—please credit the original author.

© 2025 Daniel Saenz
