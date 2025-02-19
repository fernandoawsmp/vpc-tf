output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_ids" {
  value = aws_subnet.public.*.id
}

output "private_subnet_ids" {
  value = aws_subnet.private.*.id
}

output "instance_ip" {
  description = "Ip da instancia ec2-n8n"
  value       = aws_instance.this.public_ip
}

output "sqs_queue_url" {
  description = "URL da fila SQS"
  value       = aws_sqs_queue.n8n_sqs.url
}

output "sqs_queue_arn" {
  description = "ARN da fila SQS"
  value       = aws_sqs_queue.n8n_sqs.arn
}