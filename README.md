# AWS Infrastructure as Code (IaC)

This repository contains all the Terraform configurations required to provision and manage the AWS infrastructure for my personal portfolio site. Everything—from the S3 static site bucket to CloudFront CDN, origin access, and Route 53 DNS records—is (more to come) defined here as code and deployed via a CI/CD pipeline.

---

## 🚀 Overview

* **Language & Tools**: Terraform (HCL), AWS Provider
* **Services**:

  * **S3**: Private bucket for hosting static assets
  * **CloudFront**: CDN distribution with Origin Access Identity
  * **Route 53**: DNS zone and alias records for custom domain
  * **AWS ECR**: Registry to host your Docker images
  * **API Gateway**: API configuration for serverless API
  * **Lambda**: Lambda function that runs Docker Container 
  * **CloudWatch**: To save application logs (retention 3 days only)
* **Pipeline**: Fully automated GitHub Actions workflow for `terraform init`, `plan`, and `apply` on merges to `main`.

---

## 🔧 Prerequisites

1. **Terraform** v1.5+ installed locally.
2. **AWS CLI** configured with an IAM principal having:

   * S3, CloudFront, Route 53 permissions (least-privilege applied)
   * `acm:ListCertificates` in us-east-1
3. **GitHub repository secrets** set:

   * `AWS_ACCESS_KEY_ID` - Get it from your AWS user
   * `AWS_SECRET_ACCESS_KEY` - Get it from your AWS user
   * `AWS_REGION` - Default region where you plan to deploy your infra
   * `BUCKET_NAME` - S3 where portfolio will be deployed 
   * `DOMAIN_NAME` - Your custom domain name (you need this prior)
   * `API_IMAGE_URI` - This is needed to find API image in ECR
   * `DATABASE_URL` -  API microservice needs this env set 

---

## ⚙️ Getting Started (Local)

1. **Clone the repo**

   ```bash
   git clone https://github.com/disaenz/aws-iac.git
   cd aws-iac
   ```

2. **🚀 First-Time Bootstrap**  
Before your CI pipeline can manage Terraform state in S3, you must run an initial local provisioning step to create the bucket and push the state file up. For example:

   ```bash
   # Initialize Terraform locally
   terraform init

   # Apply to provision resources and generate terraform.tfstate
   terraform apply -auto-approve

   # Upload the state file into S3 (replace BUCKET and KEY as needed)
   aws s3 cp terraform.tfstate s3://$BUCKET_NAME-iac/terraform.tfstate
   ```

 Once that’s done, your GitHub Actions pipeline will automatically pick up the S3-backed state for all future runs.

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
| `ecr_api_repository_name`  | AWS ECR repository name          | **Required**  |
| `database_url`  | Microservice env for Database          | **Required**  |


Check `variables.tf` for full list.

---

## 📦 Outputs

* `cloudfront_domain_name`: The generated CloudFront distribution domain.
* `website_endpoint`: The S3 static website endpoint (useful for testing).

---

## ⚖️ License & Attribution

This repository is a personal portfolio maintained by Daniel Saenz. Feel free to fork and adapt it for your own use. If you do, please credit the original author in your project documentation or README.
This project is open source under the [MIT License](./license.md).  

© 2025 Daniel Saenz
