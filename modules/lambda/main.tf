provider "aws" {
  region = var.region
}

# Crée un rôle IAM que les Lambdas vont utiliser pour avoir les permissions nécessaires
resource "aws_iam_role" "lambda_role" {
  name = "lambda_cleanup_role"

  # Politique qui permet à Lambda de "s'assumer" (prendre ce rôle)
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

# Document JSON définissant qui peut assumer ce rôle (ici le service Lambda)
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]             # Action autorisée
    principals {
      type        = "Service"                # Type d'entité qui assume ce rôle
      identifiers = ["lambda.amazonaws.com"] # C'est le service Lambda d'AWS
    }
  }
}

resource "aws_iam_policy" "lambda_policy" {
  name = "lambda_cleanup_policy"

  policy = jsonencode({                      # encode en JSON la politique IAM
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"                    # Autorise les actions suivantes
        Action = [
          "dynamodb:Scan",                  # Lecture complète de la table DynamoDB
          "dynamodb:UpdateItem",            # Mise à jour d'un élément dans DynamoDB
          "iam:UpdateUser",                 # Modifier un utilisateur IAM
          "iam:ListUserTags",               # Lister les tags d'un utilisateur IAM
          "tag:GetResources",               # Lire les ressources taguées (Tagging API)
          "ses:SendEmail",                  # Envoyer des emails via SES (notifications)
          "kms:Decrypt",                    # Décrypter les secrets avec KMS
          "secretsmanager:GetSecretValue"  # Accéder aux secrets dans Secrets Manager
        ]
        Resource = "*"                      # Appliqué à toutes les ressources (simplifié)
      }
    ]
  })
}