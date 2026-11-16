# ChronoAccess: Automated AWS Access Management

[![terraform](https://github.com/nerminekabadou/Automated-AWS-Access-Management/actions/workflows/terraform.yml/badge.svg)](https://github.com/nerminekabadou/Automated-AWS-Access-Management/actions/workflows/terraform.yml)

A serverless workflow that automates temporary access requests to AWS resources. An employee submits a request through an API. Requests for known resources go to a one-click email approval, and anything else is flagged for manual review. Every request and decision is recorded in DynamoDB. All infrastructure is defined as code with Terraform.

Built during a cloud engineering internship.

## Architecture

```
POST /request-access ──▶ API Gateway ──▶ Lambda access_request ──▶ DynamoDB AccessRequestsTable
  {user_id, resource,                         │   looks up PolicyTemplatesTable
   duration_hours}                            │
                          template found? ────┼── yes → status PENDING_APPROVAL
                                              │         SES email with approval link
                                              └── no  → status PENDING_MANUAL_REVIEW
                                                        SES email to the admin

GET /approve/{request_id} ──▶ API Gateway ──▶ Lambda approval ──▶ status APPROVED
```

| Component | Role |
|-----------|------|
| **API Gateway** (REST, `prod` stage) | `POST /request-access`, `GET /approve/{request_id}` (approval links are clicked from an email, hence GET) |
| **Lambda** (Python 3.11) | `access_request_handler.py` validates and stores requests and sends notifications; `approval_handler.py` approves a request |
| **DynamoDB** | `AccessRequestsTable` (with a `UserIndex` GSI on `user_id`) and `PolicyTemplatesTable` (pre-approved policy per resource) |
| **SES** | Approval and manual-review emails |
| **Terraform** | One module per service; remote state in S3 with native S3 locking |

## Repository layout

```
main.tf, variables.tf, outputs.tf   root module wiring
backend.tf, provider.tf             S3 remote state, AWS provider
modules/                            api_gateway, dynamodb, lambda, iam, s3, ses
lambda_code/                        Lambda handlers (packaged automatically by Terraform)
.gitlab-ci.yml                      validate → plan → apply pipeline used during the internship
.github/workflows/terraform.yml     fmt + validate on every push
```

## Deploy

Requirements: Terraform ≥ 1.6, an AWS profile, an existing IAM role for the Lambdas, and SES-verified sender and recipient addresses.

```bash
cp terraform.tfvars.example terraform.tfvars   # fill in your values
# edit backend.tf to point at your own state bucket
terraform init
terraform plan
terraform apply
```

Then seed `PolicyTemplatesTable` with one item per resource that can be auto-routed for approval, for example `{"resource": "s3:reports-bucket", ...}`.

### Example request

```bash
curl -X POST "$(terraform output -raw invoke_url)request-access" \
  -H "Content-Type: application/json" \
  -d '{"user_id": "intern-42", "resource": "s3:reports-bucket", "duration_hours": 2}'
```

## Roadmap
- Provision the approved IAM policy automatically and revoke it when `duration_hours` expires (EventBridge-scheduled cleanup, in progress on the `Scheduled-Cleanup` branch).
- Authenticate requesters (Cognito or IAM auth on API Gateway).

## Author
Nermine Kabadou ([@nerminekabadou](https://github.com/nerminekabadou)), with the internship team.
