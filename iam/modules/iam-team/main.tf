# ------------------------------------------------------------
# IAM Group: Developers
# ------------------------------------------------------------

# Create Group for Developers
resource "aws_iam_group" "developers" {
  name = var.team_name
}

# Dev Permission Boundary Policy
resource "aws_iam_policy" "dev_permission_boundary" {
  name        = "DevPermissionBoundary"
  description = "Limits maximum permissions for dev users"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "LimitDevPermissions"
        Effect = "Allow"
        Action = [
          "ecs:*",
          "ecr:*",
          "ssm:GetParameter",
          "ssm:DescribeParameters"
        ]
        Resource = "*"
      }
    ]
  })
}

# Dev least privilege policy
resource "aws_iam_policy" "developers_policy" {
  name        = "DevelopersPolicy"
  description = "Policy for dev team: ECS/ECR/SSM read"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ECRReadWrite"
        Effect   = "Allow"
        Action   = [
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
        Sid      = "ECSReadWrite"
        Effect   = "Allow"
        Action   = [
          "ecs:RegisterTaskDefinition",
          "ecs:UpdateService",
          "ecs:DescribeServices",
          "ecs:DescribeTasks"
        ]
        Resource = "*"
      },
      {
        Sid      = "SSMReadOnly"
        Effect   = "Allow"
        Action   = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:DescribeParameters"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach Policies to Dev Group
resource "aws_iam_group_policy_attachment" "developers_attach_policy" {
  group      = aws_iam_group.developers.name
  policy_arn = aws_iam_policy.developers_policy.arn
}

# Create a Dev User
resource "aws_iam_user" "dev_user1" {
  for_each = toset(var.users)
  name = each.value
}

# Add user to developers group
resource "aws_iam_user_group_membership" "dev_user1_group" {
  for_each =  aws_iam_user.dev_user1
  user = each.value.name
  groups = [
    aws_iam_group.developers.name
  ]
}