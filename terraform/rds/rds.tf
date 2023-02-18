resource "random_password" "password" {
  length           = 24
  special          = false
}

resource "aws_ssm_parameter" "rds" {
  name  = "/rds/postgres"
  type  = "SecureString"
  value = random_password.password.result
  tags  = var.tags

  lifecycle {
    ignore_changes = [
      value,
    ]
  }
}

resource "aws_security_group" "rds" {
  name   = "rds"
  vpc_id = var.vpc_id

#  egress {
#    from_port   = 0
#    to_port     = 0
#    protocol    = "-1"
#    cidr_blocks = ["0.0.0.0/0"]
#  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/16"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags

}

# get all the engine versions
# aws rds describe-orderable-db-instance-options --engine postgres --db-instance-class db.t4g.medium \
#     --query "*[].{EngineVersion:EngineVersion,StorageType:StorageType}|[?StorageType=='gp2']|[].{EngineVersion:EngineVersion}" \
#     --output text \
#    --region us-east-1

resource "aws_db_instance" "rds" {
  allocated_storage    = 20
  db_name              = "postgres"
  engine               = "postgres"
  engine_version       = "14.6"
  instance_class       = "db.t4g.medium"
  username             = "root"
  storage_type         = "gp3"
  password             = random_password.password.result
  skip_final_snapshot  = false
  publicly_accessible  = false
  vpc_security_group_ids = [aws_security_group.rds.id]
  performance_insights_enabled = false

  tags = var.tags
}