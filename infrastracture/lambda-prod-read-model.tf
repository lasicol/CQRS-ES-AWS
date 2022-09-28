
resource "aws_s3_object" "lambda_prod_read_model" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "prodReadModel.zip"
  source = "${path.module}/../.serverless/prodReadModelHandler.zip"

  etag = filemd5("${path.module}/../.serverless/prodReadModelHandler.zip")
}

resource "aws_lambda_function" "prod_read_model" {
  function_name = "blaszewski-prodReadModel"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_prod_read_model.key

  runtime = "nodejs14.x"
  handler = "src/lambda/product.read.model/index.handler"

  source_code_hash = "${filebase64sha256("${path.module}/../.serverless/prodReadModelHandler.zip")}"

  role = aws_iam_role.RoleProductReadModel.arn

  tags = {
    Owner = "blaszewski"
    Name = "blaszewski-lambda-prod-read-model"
  }
}

resource "aws_cloudwatch_log_group" "prod_read_model" {
  name = "/aws/lambda/${aws_lambda_function.prod_read_model.function_name}"

  retention_in_days = 30
}


resource "aws_iam_role" "RoleProductReadModel" {
  name = "RoleProdReadModel_lambda"

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

resource "aws_iam_role_policy_attachment" "ProdReadModel_policy" {
  role       = aws_iam_role.RoleProductReadModel.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
}

resource "aws_iam_role_policy" "ProdReadModel_dynamodb_read_log_policy" {
  name   = "CatReadModel-dynamodb-log-policy"
  role   = aws_iam_role.RoleProductReadModel.id
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

resource "aws_lambda_event_source_mapping" "map_lambda_with_sqs_product_queue" {
  event_source_arn  = aws_sqs_queue.product_queue.arn
  function_name     = aws_lambda_function.prod_read_model.arn
}


