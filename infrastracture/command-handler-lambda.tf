# data "archive_file" "lambda_command_handler" {
#   type = "zip"

#   source_dir  = "${path.module}/../lambda/dist/command.handler"
#   output_path = "${path.module}/../dist/command.handler.zip"
# }

resource "aws_s3_object" "lambda_command_handler" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "commandHandler.zip"
  source = "${path.module}/../.serverless/commandHandler.zip"

  etag = filemd5("${path.module}/../.serverless/commandHandler.zip")
}

resource "aws_lambda_function" "command_handler" {
  function_name = "blaszewski-CommandHandler"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_command_handler.key

  runtime = "nodejs14.x"
  handler = "src/lambda/command.handler/index.handler"

  source_code_hash = "${filebase64sha256("${path.module}/../.serverless/commandHandler.zip")}"

  role = aws_iam_role.lambda_exec.arn

  tags = {
    Owner = "blaszewski"
    Name = "blaszewski-lambda-command-handler"
  }
}

resource "aws_cloudwatch_log_group" "command_handler" {
  name = "/aws/lambda/${aws_lambda_function.command_handler.function_name}"

  retention_in_days = 30
}