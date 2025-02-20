# Criar um Security Group para o RDS
resource "aws_security_group" "rds_sg" {
  name   = "db-n8n"
  vpc_id = aws_vpc.this.id
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = []
    security_groups = [
      aws_security_group.this.id
    ]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "db-n8n"
  }
}

