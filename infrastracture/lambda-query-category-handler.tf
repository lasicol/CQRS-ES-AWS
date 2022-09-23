# data "archive_file" "lambda_command_handler" {
#   type = "zip"

#   source_dir  = "${path.module}/../lambda/dist/command.handler"
#   output_path = "${path.module}/../dist/command.handler.zip"
# }

resource "aws_s3_object" "lambda_query_cat_handler" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "queryCategoryHandler.zip"
  source = "${path.module}/../.serverless/queryCategoryHandler.zip"

  etag = filemd5("${path.module}/../.serverless/queryCategoryHandler.zip")
}

resource "aws_lambda_function" "query_cat_handler" {
  function_name = "blaszewski-queryCategoryHandler"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_query_cat_handler.key

  runtime = "nodejs14.x"
  handler = "src/lambda/query.category.handler/index.handler"

  source_code_hash = "${filebase64sha256("${path.module}/../.serverless/queryCategoryHandler.zip")}"

  role = aws_iam_role.RoleCatReadModel.arn

  tags = {
    Owner = "blaszewski"
    Name = "blaszewski-lambda-queryCategoryHandler"
  }
}

resource "aws_cloudwatch_log_group" "query_cat_handler" {
  name = "/aws/lambda/${aws_lambda_function.query_cat_handler.function_name}"

  retention_in_days = 30
}


