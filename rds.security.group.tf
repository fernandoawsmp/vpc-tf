# Criar um Security Group para o RDS
resource "aws_security_group" "rds_sg" {
  vpc_id = aws_vpc.this.id
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # Permite acesso apenas da VPC
  }
}