output "aws_iam_role" {
  value = aws_iam_role.bucket_role.arn
}

output "aws_ecr_db_repo" {
  value = aws_ecr_repository.db.repository_url
}

output "aws_ecr_backend_repo" {
  value = aws_ecr_repository.backend.repository_url
}