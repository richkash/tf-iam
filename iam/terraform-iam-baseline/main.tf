terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# ------------------------------------------------------------
# IAM Account Password Policy
# ------------------------------------------------------------

resource "aws_iam_account_password_policy" "default" {
  minimum_password_length        = 10
  require_symbols                = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_lowercase_characters   = true
  allow_users_to_change_password = true
  max_password_age               = 90
  password_reuse_prevention      = 5
}

# ------------------------------------------------------------
# IAM User for GitHub Actions
# ------------------------------------------------------------

resource "aws_iam_user" "github_actions_user" {
  name          = "github-actions-user"
  path          = "/"
  force_destroy = false
  tags = {
    "CreatedBy" = "Terraform"
    "Purpose"   = "GitHub Actions CI/CD"
  }
}

# ------------------------------------------------------------
# IAM Admin Group and Attachments
# ------------------------------------------------------------

resource "aws_iam_group" "admin" {
  name = "admin"
}


# ------------------------------------------------------------
# Custom Policy for GitHub Actions CI
# ------------------------------------------------------------

resource "aws_iam_policy" "github_actions_ci_policy" {
  name        = "GitHubActionsCIPolicy"
  description = "Custom policy for GitHub Actions CI/CD user"
  path        = "/"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ECRPushPull"
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage"
        ]
        Resource = "*"
      },
      {
        Sid    = "ECSDeploy"
        Effect = "Allow"
        Action = [
          "ecs:RegisterTaskDefinition",
          "ecs:UpdateService",
          "ecs:DescribeServices",
          "ecs:DescribeTaskDefinition",
          "ecs:DescribeTasks"
        ]
        Resource = "*"
      },
      {
        Sid    = "IAMReadOnly"
        Effect = "Allow"
        Action = [
          "iam:ListRoles",
          "iam:GetRole",
          "iam:ListAttachedRolePolicies",
          "iam:GetPolicy",
          "iam:GetPolicyVersion"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "github_actions_user_custom_policy" {
  user       = aws_iam_user.github_actions_user.name
  policy_arn = aws_iam_policy.github_actions_ci_policy.arn
}
