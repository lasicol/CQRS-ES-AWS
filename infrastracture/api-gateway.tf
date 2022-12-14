resource "aws_apigatewayv2_api" "lambda" {
  name          = "serverless_lambda_gw"
  protocol_type = "HTTP"
  tags = {
    Owner = "blaszewski"
    Name = "blaszewski-lambda-gw-hello"
  }
}

resource "aws_apigatewayv2_stage" "lambda" {
  api_id = aws_apigatewayv2_api.lambda.id

  name        = "serverless_lambda_stage"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

resource "aws_apigatewayv2_integration" "hello_command" {
  api_id = aws_apigatewayv2_api.lambda.id

  integration_uri    = aws_lambda_function.command_handler.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}
resource "aws_apigatewayv2_integration" "query_category" {
  api_id = aws_apigatewayv2_api.lambda.id

  integration_uri    = aws_lambda_function.query_cat_handler.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}
resource "aws_apigatewayv2_integration" "query_product" {
  api_id = aws_apigatewayv2_api.lambda.id

  integration_uri    = aws_lambda_function.query_prod_handler.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "hello_command" {
  api_id = aws_apigatewayv2_api.lambda.id

  route_key = "GET /hellocommand"
  target    = "integrations/${aws_apigatewayv2_integration.hello_command.id}"
}

resource "aws_apigatewayv2_route" "post_product" {
  api_id = aws_apigatewayv2_api.lambda.id

  route_key = "POST /product"
  target    = "integrations/${aws_apigatewayv2_integration.hello_command.id}"
}
resource "aws_apigatewayv2_route" "put_product" {
  api_id = aws_apigatewayv2_api.lambda.id

  route_key = "PUT /product"
  target    = "integrations/${aws_apigatewayv2_integration.hello_command.id}"
}

resource "aws_apigatewayv2_route" "post_product_category" {
  api_id = aws_apigatewayv2_api.lambda.id

  route_key = "POST /product_category"
  target    = "integrations/${aws_apigatewayv2_integration.hello_command.id}"
}

resource "aws_apigatewayv2_route" "get_product_categories" {
  api_id = aws_apigatewayv2_api.lambda.id

  route_key = "GET /product_category"
  target    = "integrations/${aws_apigatewayv2_integration.query_category.id}"
}
resource "aws_apigatewayv2_route" "get_products" {
  api_id = aws_apigatewayv2_api.lambda.id

  route_key = "GET /product"
  target    = "integrations/${aws_apigatewayv2_integration.query_product.id}"
}

resource "aws_cloudwatch_log_group" "api_gw" {
  name = "/aws/api_gw/${aws_apigatewayv2_api.lambda.name}"

  retention_in_days = 30
}

resource "aws_lambda_permission" "api_gw2" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.command_handler.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}
resource "aws_lambda_permission" "api_gw_query_cat_handler" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.query_cat_handler.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}
resource "aws_lambda_permission" "api_gw_query_prod_handler" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.query_prod_handler.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}
