
variable "tags" {
  type = map(string)
  default = {
    Environment = "production"
    Project     = "Projeto-3"
  }
}

variable "aws_provider" {
  type = object({
    region = string,
    assume_role = object({
      role_arn = string
    })
  })

  default = {
    region = "us-east-1"
    assume_role = {
      role_arn = "arn:aws:iam::767397833843:role/terraform-projeto3"
    }
  }
}

variable "vpc" {
  type = object({
    name                     = string
    cidr_block               = string
    internet_gateway_name    = string
    public_route_table_name  = string
    private_route_table_name = string
    public_subnets = list(object({
      name                    = string
      cidr_block              = string
      availability_zone       = string
      map_public_ip_on_launch = bool
    })),
    private_subnets = list(object({
      name                    = string
      cidr_block              = string
      availability_zone       = string
      map_public_ip_on_launch = bool
    }))
  })
  default = {
    cidr_block               = "10.0.0.0/24"
    name                     = "vpc-projeto3"
    internet_gateway_name    = "internet-gateway"
    public_route_table_name  = "public-route-table"
    private_route_table_name = "private-route-table"
    public_subnets = [{
      name                    = "public-subnet-us-east-1a"
      cidr_block              = "10.0.0.0/26"
      availability_zone       = "us-east-1a"
      map_public_ip_on_launch = true
      },
      {
        name                    = "public-subnet-us-east-1b"
        cidr_block              = "10.0.0.64/26"
        availability_zone       = "us-east-1b"
        map_public_ip_on_launch = true
    }]
    private_subnets = [{
      name                    = "private-subnet-us-east-1a"
      cidr_block              = "10.0.0.128/26"
      availability_zone       = "us-east-1a"
      map_public_ip_on_launch = false
      },
      {
        name                    = "private-subnet-us-east-1b"
        cidr_block              = "10.0.0.192/26"
        availability_zone       = "us-east-1b"
        map_public_ip_on_launch = false
    }]
  }
}

variable "aws_instance_name" {
  description = "Name of the EC2 instance"
  default     = "ec2-n8n"
}

# Variáveis do RDS
variable "rds_identifier" {
  description = "Identificador da instância RDS"
  type        = string
  default     = "n8n"
}

variable "rds_allocated_storage" {
  description = "Espaço alocado para o RDS (em GB)"
  type        = number
  default     = 20
}

variable "rds_engine" {
  description = "Engine do RDS"
  type        = string
  default     = "postgres"
}

variable "rds_instance_class" {
  description = "Classe da instância do RDS"
  type        = string
  default     = "db.t4g.small"
}

variable "rds_db_name" {
  description = "Nome do banco de dados"
  type        = string
  default     = "n8n"
}

variable "rds_username" {
  description = "Usuário do banco de dados"
  type        = string
  default     = "postgres"
}

variable "rds_password" {
  description = "Senha do banco de dados"
  type        = string
  sensitive   = true
  default     = "postgres"
}

variable "rds_skip_final_snapshot" {
  description = "Pular ou não o snapshot final na deleção"
  type        = bool
  default     = true
}

variable "sqs_name" {
  description = "Nome da fila SQS"
  default     = "n8n"
}