# data "archive_file" "lambda_hello_world" {
#   type = "zip"

#   source_dir  = "${path.module}/../lambda/dist/hello-world"
#   output_path = "${path.module}/../dist/hello-world.zip"
# }

resource "aws_s3_object" "lambda_hello_world" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "helloHandler.zip"
  source = "${path.module}/../.serverless/helloHandler.zip"

  etag = filemd5("${path.module}/../.serverless/helloHandler.zip")
}

resource "aws_lambda_function" "hello_world" {
  function_name = "blaszewski-HelloWorld"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_hello_world.key

  runtime = "nodejs12.x"
  handler = "hello.handler"

 source_code_hash = "${filebase64sha256("${path.module}/../.serverless/helloHandler.zip")}"

  role = aws_iam_role.lambda_exec.arn

  tags = {
    Owner = "blaszewski"
    Name = "blaszewski-lambda-hello"
  }
}

resource "aws_cloudwatch_log_group" "hello_world" {
  name = "/aws/lambda/${aws_lambda_function.hello_world.function_name}"

  retention_in_days = 30
}

resource "aws_iam_role" "lambda_exec" {
  name = "serverless_lambda"

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

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "dynamodb_read_log_policy" {
  name   = "lambda-dynamodb-log-policy"
  role   = aws_iam_role.lambda_exec.id
  policy = jsonencode(
{
  "Version": "2012-10-17",
  "Statement": [
{
			"Effect": "Allow",
			"Action": [
				"dynamodb:BatchGetItem",
				"dynamodb:GetItem",
				"dynamodb:Query",
				"dynamodb:Scan",
				"dynamodb:BatchWriteItem",
				"dynamodb:PutItem",
				"dynamodb:UpdateItem"
			],
			"Resource": ["${aws_dynamodb_table.event_store.arn}",
          "${aws_dynamodb_table.event_store.arn}/*"]
		}
  ]
})
}