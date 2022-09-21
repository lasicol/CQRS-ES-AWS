resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "blaszewski-lambda"
  tags = {
    Owner = "blaszewski"
    Name = "blaszewski-lambda"
  }
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.lambda_bucket.id
  acl    = "private"
}
