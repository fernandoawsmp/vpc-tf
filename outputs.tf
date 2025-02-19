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

output "rds_endpoint" {
  value = aws_db_instance.n8n_db.endpoint
  description = "Endpoint do RDS PostgreSQL"
}
