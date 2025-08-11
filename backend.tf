#Backend config implementation to track state of the infrastructure deployed on the AWS account
terraform {
  backend "s3" {
    bucket         = "our-terraform-state-bucket"
    key            = "internshipproject/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}