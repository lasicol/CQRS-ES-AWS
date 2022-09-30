
resource "aws_s3_object" "lambda_archive_event" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "archiveEvent.zip"
  source = "${path.module}/../.serverless/archiveEventHandler.zip"

  etag = filemd5("${path.module}/../.serverless/archiveEventHandler.zip")
}

resource "aws_lambda_function" "archive_event" {
  function_name = "blaszewski-archiveEvent"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_archive_event.key

  runtime = "nodejs14.x"
  handler = "src/lambda/archive.event/index.handler"

  source_code_hash = "${filebase64sha256("${path.module}/../.serverless/archiveEventHandler.zip")}"

  role = aws_iam_role.RoleArchiveEvent.arn

  tags = {
    Owner = "blaszewski"
    Name = "blaszewski-lambda-archive-event"
  }
}

resource "aws_cloudwatch_log_group" "archive_event" {
  name = "/aws/lambda/${aws_lambda_function.archive_event.function_name}"

  retention_in_days = 30
}


resource "aws_iam_role" "RoleArchiveEvent" {
  name = "RoleArchiveEvent_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "archiveEvent_policy" {
  role       = aws_iam_role.RoleArchiveEvent.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
}

resource "aws_iam_role_policy" "archiveEvent_policy" {
  name   = "ArchiveEvent-policy"
  role   = aws_iam_role.RoleArchiveEvent.id
  policy = jsonencode(
{
  "Version": "2012-10-17",
  "Statement": [
{
			"Effect": "Allow",
			"Action": [
                "S3:*"
			],
			"Resource": ["${aws_s3_bucket.archive_event_bucket.arn}", "${aws_s3_bucket.archive_event_bucket.arn}/*"]
		}
  ]
})
}

resource "aws_lambda_event_source_mapping" "map_lambda_with_sqs_archive_queue" {
  event_source_arn  = aws_sqs_queue.archive_queue.arn
  function_name     = aws_lambda_function.archive_event.arn
}


