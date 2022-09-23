# data "archive_file" "lambda_command_handler" {
#   type = "zip"

#   source_dir  = "${path.module}/../lambda/dist/command.handler"
#   output_path = "${path.module}/../dist/command.handler.zip"
# }

resource "aws_s3_object" "lambda_cat_read_model" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "catReadModel.zip"
  source = "${path.module}/../.serverless/catReadModelHandler.zip"

  etag = filemd5("${path.module}/../.serverless/catReadModelHandler.zip")
}

resource "aws_lambda_function" "cat_read_model" {
  function_name = "blaszewski-catReadModel"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_cat_read_model.key

  runtime = "nodejs14.x"
  handler = "src/lambda/category.read.model/index.handler"

  source_code_hash = "${filebase64sha256("${path.module}/../.serverless/catReadModelHandler.zip")}"

  role = aws_iam_role.RoleCatReadModel.arn

  tags = {
    Owner = "blaszewski"
    Name = "blaszewski-lambda-cat-read-model"
  }
}

resource "aws_cloudwatch_log_group" "cat_read_model" {
  name = "/aws/lambda/${aws_lambda_function.cat_read_model.function_name}"

  retention_in_days = 30
}


resource "aws_iam_role" "RoleCatReadModel" {
  name = "RoleCatReadModel_lambda"

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

resource "aws_iam_role_policy_attachment" "CatReadModel_policy" {
  role       = aws_iam_role.RoleCatReadModel.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
}

resource "aws_iam_role_policy" "CatReadModel_dynamodb_read_log_policy" {
  name   = "CatReadModel-dynamodb-log-policy"
  role   = aws_iam_role.RoleCatReadModel.id
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
			"Resource": ["${aws_dynamodb_table.core.arn}",
          "${aws_dynamodb_table.core.arn}/*"]
		}
  ]
})
}

resource "aws_lambda_event_source_mapping" "map_lambda_with_sqs_category_queue" {
  event_source_arn  = aws_sqs_queue.category_queue.arn
  function_name     = aws_lambda_function.cat_read_model.arn
}


