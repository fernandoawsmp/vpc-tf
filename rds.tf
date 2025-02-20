resource "aws_db_instance" "this" {
  identifier             = var.rds_identifier
  allocated_storage      = var.rds_allocated_storage
  engine                 = var.rds_engine
  instance_class         = var.rds_instance_class
  db_name                = var.rds_db_name
  username               = var.rds_username
  password               = var.rds_password
  db_subnet_group_name   = aws_db_subnet_group.rds-sub.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = var.rds_skip_final_snapshot

  tags = var.tags
}
