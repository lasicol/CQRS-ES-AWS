resource "aws_s3_object" "lambda_read_stream" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "readStreamHandler.zip"
  source = "${path.module}/../.serverless/readStreamHandler.zip"

  etag = filemd5("${path.module}/../.serverless/readStreamHandler.zip")
}

resource "aws_lambda_function" "read_stream" {
  function_name = "blaszewski-ReadStream"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_read_stream.key

  runtime = "nodejs14.x"
  handler = "src/lambda/read.stream/index.handler"

  source_code_hash = "${filebase64sha256("${path.module}/../.serverless/readStreamHandler.zip")}"

  role = aws_iam_role.lambda_read_stream.arn

  tags = {
    Owner = "blaszewski"
    Name = "blaszewski-ReadStream"
  }
}

resource "aws_cloudwatch_log_group" "read_stream" {
  name = "/aws/lambda/${aws_lambda_function.read_stream.function_name}"

  retention_in_days = 30
}

resource "aws_iam_role" "lambda_read_stream" {
  name = "serverless_lambda_read_stream"

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

resource "aws_iam_role_policy_attachment" "lambda_policy2" {
  role       = aws_iam_role.lambda_read_stream.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "read_stream_policy" {
  name   = "lambda-dynamodb-read-stream-policy"
  role   = aws_iam_role.lambda_read_stream.id
  policy = jsonencode(
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:DescribeStream",
                "dynamodb:GetRecords",
                "dynamodb:GetShardIterator",
                "dynamodb:ListStreams"
            ],
            "Resource": ["${aws_dynamodb_table.event_store.arn}/stream", "${aws_dynamodb_table.event_store.arn}/stream/*"],
        },
        {
            "Effect": "Allow",
            "Action": [
                "sns:Publish"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
})
}


resource "aws_lambda_event_source_mapping" "map_lambda_with_dynamodb" {
  event_source_arn  = aws_dynamodb_table.event_store.stream_arn
  function_name     = aws_lambda_function.read_stream.arn
  starting_position = "LATEST"
}


