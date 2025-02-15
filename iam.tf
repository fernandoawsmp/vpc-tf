resource "aws_iam_role" "role_acesso_ssm" {
  name = "role-acesso-ssm-tf"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy_attachment" "ecr_full_access" {
  name       = "ecr-full-access"
  roles      = [aws_iam_role.role_acesso_ssm.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

resource "aws_iam_policy_attachment" "ecs_full_access" {
  name       = "ecs-full-access"
  roles      = [aws_iam_role.role_acesso_ssm.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

resource "aws_iam_policy_attachment" "s3_full_access" {
  name       = "s3-full-access"
  roles      = [aws_iam_role.role_acesso_ssm.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_policy_attachment" "ssm_attach_ssm" {
  name       = "ssm-attach-ssm"
  roles      = [aws_iam_role.role_acesso_ssm.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy_attachment" "secrets_manager_read_write" {
  name       = "secrets-manager-read-write"
  roles      = [aws_iam_role.role_acesso_ssm.name]
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

resource "aws_iam_instance_profile" "role_acesso_ssm" {
  name = "role-acesso-ssm-tf"
  role = aws_iam_role.role_acesso_ssm.name
}