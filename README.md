AWS ECS Deployment with Terraform, Docker & GitHub Actions (OIDC)

This repository demonstrates a complete CI/CD pipeline to deploy a Dockerized application on AWS ECS (Fargate) using Terraform and GitHub Actions with OIDC authentication and an S3 backend for remote state management.

1. Create S3 Bucket & DynamoDB Table for Terraform Remote State
Terraform stores the infrastructure state remotely in S3, ensuring consistent access across all environments and team members.

Step 1 — Create S3 Bucket:
•	aws s3 mb s3://ecs-deployment-pratik --region ap-south-1

Step 2 — Enable Versioning:
•	aws s3api put-bucket-versioning --bucket ecs-deployment-pratik --versioning-configuration Status=Enabled


Step 4 — Configure Terraform Backend:
terraform {
  backend "s3" {
    bucket         = "ecs-deployment-pratik"
    key            = "hello-ecs/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
  }
}

2. Configure OIDC for GitHub → AWS Authentication
OpenID Connect (OIDC) allows GitHub Actions to access AWS securely without storing long-term credentials.
Step 1 — Create OIDC Provider:
•	aws iam create-open-id-connect-provider --url https://token.actions.githubusercontent.com --client-id-list sts.amazonaws.com --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1

Step 2 — Create Trust Policy (trust-policy.json):
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "Federated": "arn:aws:iam::<ACCOUNT_ID>:oidc-provider/token.actions.githubusercontent.com"
    },
    "Action": "sts:AssumeRoleWithWebIdentity",
    "Condition": {
      "StringLike": {
        "token.actions.githubusercontent.com:sub": "repo:<GITHUB_USERNAME>/<REPO>:*"
      },
      "StringEquals": {
        "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
      }
    }
  }]
}
Step 3 — Create Role for GitHub Actions:
•	aws iam create-role --role-name github-oidc-deploy --assume-role-policy-document file://trust-policy.json
Step 4 — Attach Permissions Policy (permissions-policy.json):
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": [
      "ecs:*", "ecr:*", "iam:*", "s3:*", "ec2:*",
      "elasticloadbalancing:*", "logs:*", "cloudwatch:*", "sts:GetCallerIdentity"
    ],
    "Resource": "*"
  }]
}

3. Configure GitHub Workflows
This project uses two GitHub Actions workflows to manage infrastructure automation.
Apply Workflow — build-scan-deploy.yml
• Triggers on push to main branch or manually
• Builds Docker image and pushes to ECR
• Deploys ECS + ALB using Terraform
Destroy Workflow — terraform-destroy.yml
• Trigger manually via workflow dispatch
• Configures AWS credentials via OIDC
• Runs terraform destroy using remote S3 state

4. Test the Deployed Application
After Terraform completes, it will output the ALB DNS name. Test using:
curl http://<ALB-DNS-NAME>/health
Expected output: {"status":"ok"}

5. Destroy Infrastructure
Trigger the Destroy Workflow from GitHub Actions manually to remove all AWS resources.
Ensure the ECR repository has force_delete = true for automatic cleanup.

6. Troubleshooting
- Ensure backend.tf points to your S3 bucket.
- Verify OIDC IAM role permissions if authentication fails.
- Check security groups and target group health if ALB is unreachable.
- Ensure Terraform state is correctly configured in S3 for destroy to work.
