resource "aws_s3_object" "lambda_error_notify" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "errorNotifyHandler.zip"
  source = "${path.module}/../.serverless/errorNotifyHandler.zip"

  etag = filemd5("${path.module}/../.serverless/errorNotifyHandler.zip")
}

resource "aws_lambda_function" "error_notify" {
  function_name = "blaszewski-ErrorNotify"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_error_notify.key

  runtime = "nodejs14.x"
  handler = "src/lambda/error.notify/index.handler"

  source_code_hash = "${filebase64sha256("${path.module}/../.serverless/errorNotifyHandler.zip")}"

  role = aws_iam_role.lambda_error_notify.arn

  tags = {
    Owner = "blaszewski"
    Name = "blaszewski-ErrorNotify"
  }
}

resource "aws_cloudwatch_log_group" "error_notify" {
  name = "/aws/lambda/${aws_lambda_function.error_notify.function_name}"

  retention_in_days = 30
}

resource "aws_iam_role" "lambda_error_notify" {
  name = "serverless_lambda_error_notify"

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

resource "aws_iam_role_policy" "error_notify_policy" {
  name   = "lambda-error_notify-policy"
  role   = aws_iam_role.lambda_error_notify.id
  policy = jsonencode(
{
    "Version": "2012-10-17",
    "Statement": [
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

resource "aws_iam_role_policy_attachment" "lambda_error_notify_policy" {
  role       = aws_iam_role.lambda_error_notify.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_permission" "query_prod_handler-allow-cloudwatch" {
  statement_id  = "query_prod_handler-allow-cloudwatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.error_notify.function_name}"
  principal     = "logs.us-east-1.amazonaws.com"
  source_arn    = "${aws_cloudwatch_log_group.query_prod_handler.arn}:*"
}

resource "aws_cloudwatch_log_subscription_filter" "query_prod_handler-cloudwatch-lambda-subscription" {
  depends_on      =  [aws_lambda_permission.query_prod_handler-allow-cloudwatch]
  name            = "cloudwatch-error-notify-lambda-subscription"
  log_group_name  = "${aws_cloudwatch_log_group.query_prod_handler.name}"
  filter_pattern  = "ERROR"
  destination_arn = "${aws_lambda_function.error_notify.arn}"
}

resource "aws_lambda_permission" "query_cat_handler-allow-cloudwatch" {
  statement_id  = "query_cat_handler-allow-cloudwatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.error_notify.function_name}"
  principal     = "logs.us-east-1.amazonaws.com"
  source_arn    = "${aws_cloudwatch_log_group.query_cat_handler.arn}:*"
}

resource "aws_cloudwatch_log_subscription_filter" "query_cat_handler-cloudwatch-lambda-subscription" {
  depends_on      =  [aws_lambda_permission.query_cat_handler-allow-cloudwatch]
  name            = "cloudwatch-error-notify-lambda-subscription"
  log_group_name  = "${aws_cloudwatch_log_group.query_cat_handler.name}"
  filter_pattern  = "ERROR"
  destination_arn = "${aws_lambda_function.error_notify.arn}"
}

resource "aws_lambda_permission" "archive_event-allow-cloudwatch" {
  statement_id  = "archive_event-allow-cloudwatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.error_notify.function_name}"
  principal     = "logs.us-east-1.amazonaws.com"
  source_arn    = "${aws_cloudwatch_log_group.archive_event.arn}:*"
}

resource "aws_cloudwatch_log_subscription_filter" "archive_event-cloudwatch-lambda-subscription" {
  depends_on      =  [aws_lambda_permission.archive_event-allow-cloudwatch]
  name            = "cloudwatch-error-notify-lambda-subscription"
  log_group_name  = "${aws_cloudwatch_log_group.archive_event.name}"
  filter_pattern  = "ERROR"
  destination_arn = "${aws_lambda_function.error_notify.arn}"
}

resource "aws_lambda_permission" "cat_read_model-allow-cloudwatch" {
  statement_id  = "cat_read_model-allow-cloudwatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.error_notify.function_name}"
  principal     = "logs.us-east-1.amazonaws.com"
  source_arn    = "${aws_cloudwatch_log_group.cat_read_model.arn}:*"
}

resource "aws_cloudwatch_log_subscription_filter" "cat_read_model-cloudwatch-lambda-subscription" {
  depends_on      =  [aws_lambda_permission.cat_read_model-allow-cloudwatch]
  name            = "cloudwatch-error-notify-lambda-subscription"
  log_group_name  = "${aws_cloudwatch_log_group.cat_read_model.name}"
  filter_pattern  = "ERROR"
  destination_arn = "${aws_lambda_function.error_notify.arn}"
}

resource "aws_lambda_permission" "command_handler-allow-cloudwatch" {
  statement_id  = "command_handler-allow-cloudwatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.error_notify.function_name}"
  principal     = "logs.us-east-1.amazonaws.com"
  source_arn    = "${aws_cloudwatch_log_group.command_handler.arn}:*"
}

resource "aws_cloudwatch_log_subscription_filter" "command_handler-cloudwatch-lambda-subscription" {
  depends_on      =  [aws_lambda_permission.command_handler-allow-cloudwatch]
  name            = "cloudwatch-error-notify-lambda-subscription"
  log_group_name  = "${aws_cloudwatch_log_group.command_handler.name}"
  filter_pattern  = "ERROR"
  destination_arn = "${aws_lambda_function.error_notify.arn}"
}

resource "aws_lambda_permission" "prod_read_model-allow-cloudwatch" {
  statement_id  = "prod_read_model-allow-cloudwatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.error_notify.function_name}"
  principal     = "logs.us-east-1.amazonaws.com"
  source_arn    = "${aws_cloudwatch_log_group.prod_read_model.arn}:*"
}

resource "aws_cloudwatch_log_subscription_filter" "prod_read_model-cloudwatch-lambda-subscription" {
  depends_on      =  [aws_lambda_permission.prod_read_model-allow-cloudwatch]
  name            = "cloudwatch-error-notify-lambda-subscription"
  log_group_name  = "${aws_cloudwatch_log_group.prod_read_model.name}"
  filter_pattern  = "ERROR"
  destination_arn = "${aws_lambda_function.error_notify.arn}"
}

resource "aws_lambda_permission" "read_stream-allow-cloudwatch" {
  statement_id  = "read_stream-allow-cloudwatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.error_notify.function_name}"
  principal     = "logs.us-east-1.amazonaws.com"
  source_arn    = "${aws_cloudwatch_log_group.read_stream.arn}:*"
}

resource "aws_cloudwatch_log_subscription_filter" "read_stream-cloudwatch-lambda-subscription" {
  depends_on      =  [aws_lambda_permission.read_stream-allow-cloudwatch]
  name            = "cloudwatch-error-notify-lambda-subscription"
  log_group_name  = "${aws_cloudwatch_log_group.read_stream.name}"
  filter_pattern  = "ERROR"
  destination_arn = "${aws_lambda_function.error_notify.arn}"
}


resource "aws_sns_topic" "error-notify" {
  name                        = "blaszewski-error-notify"
}

resource "aws_sns_topic_subscription" "error_notify_email_subscription" {
  topic_arn = aws_sns_topic.error-notify.arn
  protocol  = "email"
  endpoint  = "lasicb.spam@gmail.com"
}