provider "aws" {
  region = var.region
  profile = "talan-admin"
  default_tags {
    tags = {
      internship = "true"
    }
  }
}
