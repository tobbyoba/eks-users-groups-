
resource "aws_iam_user_login_profile" "Admin_user" {
  count                   = length(var.admins)
  user                    = aws_iam_user.admin_users[count.index].name
  password_reset_required = true
  #  pgp_key                 = "keybase:kenmak"
}

resource "aws_iam_user_login_profile" "dev_user" {
  count                   = length(var.developers)
  user                    = aws_iam_user.dev_users[count.index].name
  password_reset_required = true
  pgp_key                 = "keybase:kenmak"
}


resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length        = 8
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_symbols                = true
  allow_users_to_change_password = true
}

resource "aws_iam_group" "eks-admin" {
  name = "admin"
}

resource "aws_iam_group" "eks_developer" {
  name = "Developer"
}

resource "aws_iam_group_policy" "admin_policy" {
  name   = "admin"
  group  = aws_iam_group.eks-admin.name
  policy = data.aws_iam_policy_document.admin_role.json
}

resource "aws_iam_group_policy" "developer_policy" {
  name   = "developer"
  group  = aws_iam_group.eks_developer.name
  policy = data.aws_iam_policy_document.developer_role.json
}

resource "aws_iam_group_membership" "db_team" {
  name  = "dev-group-membership"
  users = aws_iam_user.dev_users[*].name
  group = aws_iam_group.eks_developer.name
}

resource "aws_iam_user" "dev_users" {
  count         = length(var.developers)
  name          = element(var.developers, count.index)
  force_destroy = true

  tags = {
    Department = "eks-dev-user"
  }
}

resource "aws_iam_user" "admin_users" {
  count         = length(var.admins)
  name          = element(var.admins, count.index)
  force_destroy = true

  tags = {
    Department = "eks-admin-user"
  }
}

resource "aws_iam_group_membership" "admin_team" {
  name  = "admin-group-membership"
  users = aws_iam_user.admin_users[*].name
  group = aws_iam_group.eks-admin.name
}

resource "aws_iam_role" "admin" {
  name               = "admin-eks-Role"
  assume_role_policy = data.aws_iam_policy_document.admin_assume_role.json
}

resource "aws_iam_role_policy_attachment" "admin-policy" {
  role       = aws_iam_role.admin.name
  policy_arn = aws_iam_policy.eks-admin.arn
}

resource "aws_iam_policy" "eks-admin" {
  name   = "eks_admin"
  policy = data.aws_iam_policy_document.admin.json
}

resource "aws_iam_role" "developer" {
  name               = "dev-eks-Role"
  assume_role_policy = data.aws_iam_policy_document.dev_assume_role.json
}

resource "aws_iam_role_policy_attachment" "developer-policy" {
  role       = aws_iam_role.developer.name
  policy_arn = aws_iam_policy.eks-developer.arn
}

resource "aws_iam_policy" "eks-developer" {
  name   = "eks_dev"
  policy = data.aws_iam_policy_document.developer.json
}




