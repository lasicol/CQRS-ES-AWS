
resource "aws_s3_object" "lambda_query_prod_handler" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "queryProductHandler.zip"
  source = "${path.module}/../.serverless/queryProductHandler.zip"

  etag = filemd5("${path.module}/../.serverless/queryProductHandler.zip")
}

resource "aws_lambda_function" "query_prod_handler" {
  function_name = "blaszewski-queryProductHandler"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_query_prod_handler.key

  runtime = "nodejs14.x"
  handler = "src/lambda/query.product.handler/index.handler"

  source_code_hash = "${filebase64sha256("${path.module}/../.serverless/queryProductHandler.zip")}"

  role = aws_iam_role.RoleProductReadModel.arn

  tags = {
    Owner = "blaszewski"
    Name = "blaszewski-lambda-queryProductHandler"
  }
}

resource "aws_cloudwatch_log_group" "query_prod_handler" {
  name = "/aws/lambda/${aws_lambda_function.query_prod_handler.function_name}"

  retention_in_days = 30
}


