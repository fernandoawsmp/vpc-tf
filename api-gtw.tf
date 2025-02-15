# API Gateway
resource "aws_api_gateway_rest_api" "webhook_api" {
  name        = "webhook-api"
  description = "API Gateway para receber webhooks e enviar para Lambda"
}

# Recurso /webhook dentro do API Gateway
resource "aws_api_gateway_resource" "webhook_resource" {
  rest_api_id = aws_api_gateway_rest_api.webhook_api.id
  parent_id   = aws_api_gateway_rest_api.webhook_api.root_resource_id
  path_part   = "webhook"
}

# Método POST no API Gateway
resource "aws_api_gateway_method" "webhook_post" {
  rest_api_id   = aws_api_gateway_rest_api.webhook_api.id
  resource_id   = aws_api_gateway_resource.webhook_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

# Integração com a Lambda
resource "aws_api_gateway_integration" "lambda_webhook" {
  rest_api_id             = aws_api_gateway_rest_api.webhook_api.id
  resource_id             = aws_api_gateway_resource.webhook_resource.id
  http_method             = aws_api_gateway_method.webhook_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.webhook_lambda.invoke_arn
}

# Implantação da API Gateway
resource "aws_api_gateway_deployment" "webhook_deployment" {
  depends_on  = [aws_api_gateway_integration.lambda_webhook]
  rest_api_id = aws_api_gateway_rest_api.webhook_api.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.webhook_api))
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Criar um Stage "dev"

resource "aws_api_gateway_stage" "webhook_stage" {
  stage_name    = "dev"
  rest_api_id   = aws_api_gateway_rest_api.webhook_api.id
  deployment_id = aws_api_gateway_deployment.webhook_deployment.id
}

# Função Lambda que processa o webhook
resource "aws_lambda_function" "webhook_lambda" {
  filename      = "lambda_function.zip"
  function_name = "webhook_lambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
}

# Criar função Lambda Permission para API Gateway invocá-la
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.webhook_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.webhook_api.execution_arn}/*/*"
}

# Criar Role para a Lambda
resource "aws_iam_role" "lambda_role" {
  name = "lambda-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Associar permissões básicas à Lambda
resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


output "webhook_url" {
  value       = "https://${aws_api_gateway_rest_api.webhook_api.id}.execute-api.${var.aws_provider.region}.amazonaws.com/${aws_api_gateway_stage.webhook_stage.stage_name}/webhook"
  description = "URL do webhook"
}