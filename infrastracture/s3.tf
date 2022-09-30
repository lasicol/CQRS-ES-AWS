resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "blaszewski-lambda"
  tags = {
    Owner = "blaszewski"
    Name = "blaszewski-lambda"
  }
}
resource "aws_s3_bucket" "archive_event_bucket" {
  bucket = "blaszewski-archive-event"
  tags = {
    Owner = "blaszewski"
    Name = "blaszewski-archive-event"
  }
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.lambda_bucket.id
  acl    = "private"
}
resource "aws_s3_bucket_acl" "archive_event_bucket_acl" {
  bucket = aws_s3_bucket.archive_event_bucket.id
  acl    = "private"
}
