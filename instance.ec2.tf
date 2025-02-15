resource "aws_instance" "this" {
  ami           = "ami-0b29c89c15cfb8a6d"
  instance_type = "t4g.small"  
  subnet_id                   = aws_subnet.public[0].id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.this.id]
  iam_instance_profile        = aws_iam_instance_profile.role_acesso_ssm.name

  #user_data
  user_data = file("user_data.sh")

  #volume
  root_block_device {
    volume_size = 30
    #volume_type = "gp3"
    encrypted = true
  }
  tags = {
    Name     = var.aws_instance_name
    ambiente = "producao"
  }
}