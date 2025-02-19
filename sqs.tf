# Criação de uma fila SQS
resource "aws_sqs_queue" "n8n_sqs" {
  name                       = var.sqs_name
  visibility_timeout_seconds = 30    # Tempo limite para processamento de mensagens
  message_retention_seconds  = 86400 # Retenção de mensagens por 1 dia
  delay_seconds              = 0     # Sem atraso para envio de mensagens
  receive_wait_time_seconds  = 0     # Sem tempo de espera para polling
}

# Criação de uma política de exemplo (opcional)
resource "aws_sqs_queue_policy" "n8n_sqs_policy" {
  queue_url = aws_sqs_queue.n8n_sqs.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = "sqs:SendMessage",
        Resource  = aws_sqs_queue.n8n_sqs.arn
      }
    ]
  })
}
