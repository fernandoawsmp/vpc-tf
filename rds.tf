# Criar uma instância RDS PostgreSQL
resource "aws_db_instance" "N8N" {
  identifier             = "n8n"
  allocated_storage      = 20
  engine                 = "postgres"
  instance_class         = "db.t4g.micro"
  db_name                = "n8n"
  username               = "postgres"
  password               = "n8n"
  db_subnet_group_name   = aws_db_subnet_group.rds-sub.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true
}

