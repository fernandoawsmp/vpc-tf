resource "aws_security_group" "this" {
  name        = "ec2-n8n"
  description = "Acesso ao ec2-n8n"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "acesso para o mundo n8n"
    from_port   = 5678
    to_port     = 5678
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    description = "acesso para o mundo redis"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-n8n"
  }

}
