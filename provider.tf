provider "aws" {
  region  = var.region
  profile = var.profile
  default_tags {
    tags = {
      internship = "true"
    }
  }
}
