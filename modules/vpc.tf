# vpc.tf
# Create vpc
# Create VPC/Subnet/Security Group/Network ACL

# create the VPC
resource "aws_vpc" "My_VPC" {
  cidr_block           = var.vpcCIDRblock
  instance_tenancy     = var.instanceTenancy
  enable_dns_support   = var.dnsSupport
  enable_dns_hostnames = var.dnsHostNames

  tags = {
    Name = "My VPC"
  }
} # end resource
# create the Subnet
resource "aws_subnet" "My_VPC_Subnet" {
  vpc_id                  = aws_vpc.My_VPC.id
  cidr_block              = var.subnetCIDRblock
  map_public_ip_on_launch = var.mapPublicIP
  availability_zone       = var.availabilityZone
  tags = {
    Name = "My VPC Subnet"
    "kubernetes.io/cluster/labcluster" = "shared" #https://aws.amazon.com/premiumsupport/knowledge-center/eks-load-balancers-troubleshooting/
    "kubernetes.io/role/elb" = 1
  }
} # end resource
# create the Subnet
resource "aws_subnet" "My_VPC_Second_Subnet" {
  vpc_id                  = aws_vpc.My_VPC.id
  cidr_block              = var.subnetdataCIDRblock
  map_public_ip_on_launch = var.mapPublicIP
  availability_zone       = var.availabilityZone2
  tags = {
    Name = "My Second VPC Subnet"
    "kubernetes.io/cluster/labcluster" = "shared" #https://aws.amazon.com/premiumsupport/knowledge-center/eks-load-balancers-troubleshooting/
    "kubernetes.io/role/elb" = 1
  }
} # end resource
# Create the Security Group
resource "aws_security_group" "My_VPC_Security_Group" {
  vpc_id      = aws_vpc.My_VPC.id
  name        = "My VPC Security Group"
  description = "My VPC Security Group"

  # allow ingress of port 22
  ingress {
    cidr_blocks = var.ingressCIDRblock
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

    # allow ingress of port 443
  ingress {
    cidr_blocks = var.ingressCIDRblock
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
  }

    # allow ingress of port 80
  ingress {
    cidr_blocks = var.ingressCIDRblock
    from_port   = 80
    to_port     = 80
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
    Name        = "My VPC Security Group"
    Description = "My VPC Security Group"
  }
} # end resource

# create VPC Network access control list
resource "aws_default_network_acl" "My_VPC_Security_ACL" {
  default_network_acl_id = aws_vpc.My_VPC.default_network_acl_id
  subnet_ids = [aws_subnet.My_VPC_Subnet.id, aws_subnet.My_VPC_Second_Subnet.id]

  # allow ingress port 22
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.destinationCIDRblock
    from_port  = 22
    to_port    = 22
  }

  # allow ingress port 80 
  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = var.destinationCIDRblock
    from_port  = 80
    to_port    = 80
  }

  # allow ingress ephemeral ports 
  ingress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = var.destinationCIDRblock
    from_port  = 1024
    to_port    = 65535
  }

      # allow ingress port 443 
  ingress {
    protocol   = "tcp"
    rule_no    = 400
    action     = "allow"
    cidr_block = var.destinationCIDRblock
    from_port  = 443
    to_port    = 443
  }

  # allow egress port 22 
  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.destinationCIDRblock
    from_port  = 22
    to_port    = 22
  }

  # allow egress port 80 
  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = var.destinationCIDRblock
    from_port  = 80
    to_port    = 80
  }

  # allow egress ephemeral ports
  egress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = var.destinationCIDRblock
    from_port  = 1024
    to_port    = 65535
  }

   # allow egress port 443 
  egress {
    protocol   = "tcp"
    rule_no    = 400
    action     = "allow"
    cidr_block = var.destinationCIDRblock
    from_port  = 443
    to_port    = 443
  }
  tags = {
    Name = "My VPC ACL"
  }
} # end resource

# Create the Internet Gateway
resource "aws_internet_gateway" "My_VPC_GW" {
  vpc_id = aws_vpc.My_VPC.id
  tags = {
    Name = "My VPC Internet Gateway"
  }
} # end resource

# Create the Route Table
resource "aws_route_table" "My_VPC_route_table" {
  vpc_id = aws_vpc.My_VPC.id
  tags = {
    Name = "My VPC Route Table"
  }
} # end resource

# Create the Internet Access
resource "aws_route" "My_VPC_internet_access" {
  route_table_id         = aws_route_table.My_VPC_route_table.id
  destination_cidr_block = var.destinationCIDRblock
  gateway_id             = aws_internet_gateway.My_VPC_GW.id
} # end resource

# Associate the Route Table with the Subnet
resource "aws_route_table_association" "My_VPC_association" {
  subnet_id      = aws_subnet.My_VPC_Subnet.id
  route_table_id = aws_route_table.My_VPC_route_table.id
} # end resource

resource "aws_route_table_association" "My_VPC_association2" {
  subnet_id      = aws_subnet.My_VPC_Second_Subnet.id
  route_table_id = aws_route_table.My_VPC_route_table.id
} # end resource

resource "aws_main_route_table_association" "My_Route_Table_Association" {
  vpc_id         = aws_vpc.My_VPC.id
  route_table_id = aws_route_table.My_VPC_route_table.id
} # end resource  

resource "aws_db_subnet_group" "My_VPC_Subnet_Group" {
  name       = "labsg"
  subnet_ids = [aws_subnet.My_VPC_Subnet.id, aws_subnet.My_VPC_Second_Subnet.id ]

  tags = {
    Name = "My DB subnet group"
  }
}# end resource

# Outputs
output "aws_vpc" {
  value = aws_vpc.My_VPC.id
}
output "aws_subnet_private_prod_ids" {
  value = [aws_subnet.My_VPC_Subnet.id, aws_subnet.My_VPC_Second_Subnet.id ]
}
output "aws_subnet_group_name" {
  value = aws_db_subnet_group.My_VPC_Subnet_Group.name
}
# end outputs
# end vpc.tf
