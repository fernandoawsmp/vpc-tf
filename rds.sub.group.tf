# Cria o grupo de subnets privadas para o RDS
resource "aws_db_subnet_group" "rds-sub" {
  name       = "rds-subnet-group"
  subnet_ids = [aws_subnet.private.0.id, 
                aws_subnet.private.1.id
  ]
  description = "Subnet group for RDS"

}
