variable "region" {
  description = "Région AWS"
  default     = "us-east-1"
}

variable "iam_users_table" {
  description = "Nom de la table DynamoDB des utilisateurs IAM"
  default     = "IAMUsersTable"
}

variable "access_requests_table" {
  description = "Nom de la table DynamoDB des demandes d'accès"
  default     = "AccessRequestsTable"
}

variable "cleanup_schedule_lambda_name" {
  description = "Nom de la Lambda qui lance la recherche d'utilisateurs expirés"
  default     = "cleanupScheduleLambda"
}

variable "cleanup_lambda_name" {
  description = "Nom de la Lambda qui nettoie les ressources"
  default     = "cleanupLambda"
}

variable "schedule_expression" {
  description = "Expression de planification EventBridge (ex: rate(1 day))"
  default     = "rate(1 day)"
}
