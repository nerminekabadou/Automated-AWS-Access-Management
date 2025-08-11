#Backend config implementation to track state of the infrastructure deployed on the AWS account
terraform {
  backend "s3" {
    bucket       = "our-terraform-state-bucket-2025"
    key          = "internshipproject/terraform.tfstate"
    region       = "eu-west-2"
    use_lockfile = true # instead of dynamodb_table = "terraform-locks"  (deprecated)
    encrypt      = true
  }
}