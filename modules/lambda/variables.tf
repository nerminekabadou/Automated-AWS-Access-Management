variable "lambda_name" {}
variable "lambda_zip_path" {}
variable "handler" {}
variable "runtime" {
  default = "python3.10"
}
variable "role_arn" {}
