#db.tf
#Set up db instance

#mySql
resource "aws_db_instance" "labdb" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  name                   = "labdb"
  username               = var.DB_USER
  password               = var.DB_PASSWORD
  parameter_group_name   = "default.mysql5.7"
  db_subnet_group_name   = module.vpc.aws_subnet_group_name
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.DB_Security_Group.id]
  skip_final_snapshot    = true

  depends_on = [module.eks.wait_for_cluster_interpreter]
} # end resource

provider "mysql" {
  endpoint = aws_db_instance.labdb.endpoint
  username = var.DB_USER
  password = var.DB_PASSWORD

}

#Create DB
resource "mysql_database" "rails_dev" {
  name       = "rails_dev"
  depends_on = [module.eks.wait_for_cluster_interpreter]
} # end resource

# Create the Security Group
resource "aws_security_group" "DB_Security_Group" {
  vpc_id      = module.vpc.aws_vpc
  name        = "DB Security Group"
  description = "DB VPC Security Group"

  # allow ingress of port 3306
  ingress {
    cidr_blocks = var.ingressCIDRblock
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
  }
  # allow egress of all ports
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name        = "My DB Security Group"
    Description = "My DB Security Group"
  }
} # end resource 
# end db.tf
