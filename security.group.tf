resource "aws_security_group" "this" {
  name        = "ec2-n8n"
  description = "Acesso ao ec2-n8n"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "acesso para o mundo n8n"
    from_port   = 443
    to_port     = 443
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
