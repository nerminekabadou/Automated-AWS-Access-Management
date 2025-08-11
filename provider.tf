provider "aws" {
  region = var.region
  profile = "sandbox"
  default_tags {
    tags = {
      internship = "true"
    }
  }
}
