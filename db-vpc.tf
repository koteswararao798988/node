
#Create the vpc
resource "aws_vpc" "dbvpc" {
  cidr_block       = "20.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "dbvpc"
  }
  depends_on = [null_resource.install_kubectl]
}
#Creating IGW
resource "aws_internet_gateway" "db-igw" {
  vpc_id = aws_vpc.dbvpc.id
  tags = {

    Name = "db-igw"
  }
  depends_on = [aws_vpc.dbvpc]
}

#Creating pub-subnet1
resource "aws_subnet" "db-pub-sub-1" {
  vpc_id                  = aws_vpc.dbvpc.id
  cidr_block              = "20.0.1.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = "true"
  tags = {

    Name = "db-pub-subnet-1"
  }
  depends_on = [aws_internet_gateway.db-igw]
}
#Creating private subnet1
resource "aws_subnet" "db-pvt-sub-1" {
  vpc_id                  = aws_vpc.dbvpc.id
  cidr_block              = "20.0.2.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "db-pvt-subnet-1"
  }
  depends_on = [aws_subnet.db-pub-sub-1]
}
#Creating pub-subnet2
resource "aws_subnet" "db-pub-sub-2" {
  vpc_id                  = aws_vpc.dbvpc.id
  cidr_block              = "20.0.3.0/24"
  availability_zone       = "us-east-2b"
  map_public_ip_on_launch = "true"
  tags = {

    Name = "db-pub-subnet-2"
  }
  depends_on = [aws_subnet.db-pvt-sub-1]
}

#Creating pvt-subnet2
resource "aws_subnet" "db-pvt-sub-2" {
  vpc_id                  = aws_vpc.dbvpc.id
  cidr_block              = "20.0.4.0/24"
  availability_zone       = "us-east-2b"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "db-pvt-subnet-2"
  }
  depends_on = [aws_subnet.db-pub-sub-2]
}

#Creating pvt-subnet3
resource "aws_subnet" "db-pvt-sub-3" {
  vpc_id                  = aws_vpc.dbvpc.id
  cidr_block              = "20.0.5.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "db-pvt-subnet-3"
  }
  depends_on = [aws_subnet.db-pvt-sub-2]
}

#Creating pvt-subnet4
resource "aws_subnet" "db-pvt-sub-4" {
  vpc_id                  = aws_vpc.dbvpc.id
  cidr_block              = "20.0.6.0/24"
  availability_zone       = "us-east-2b"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "db-pvt-subnet-4"
  }
  depends_on = [aws_subnet.db-pvt-sub-3]
}

# Create elastic ip
resource "aws_eip" "db-elastic-1" {
  vpc = true
  depends_on = [aws_subnet.db-pvt-sub-4]
}
# Create Nat-gateway
resource "aws_nat_gateway" "db-nat-1" {

  allocation_id     = aws_eip.db-elastic-1.id
  subnet_id         = aws_subnet.db-pub-sub-1.id
  connectivity_type = "public"
  tags = {
    Name = "dbnat-1"
  }
  depends_on = [aws_eip.db-elastic-1]
}
# Create elastic ip
resource "aws_eip" "db-elastic-2" {
  vpc = true
  depends_on = [aws_nat_gateway.db-nat-1]
}

# Create Nat-gateway
resource "aws_nat_gateway" "db-nat-2" {

  allocation_id     = aws_eip.db-elastic-2.id
  subnet_id         = aws_subnet.db-pub-sub-2.id
  connectivity_type = "public"
  tags = {
    Name = "dbnat-2"
  }
  depends_on = [aws_eip.db-elastic-2]
}
#Create Pub-Route-table
resource "aws_route_table" "db-pub-route" {
  vpc_id = aws_vpc.dbvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.db-igw.id

  }
  tags = {
    Name = "db-pub-rot"
  }
  depends_on = [aws_nat_gateway.db-nat-2]
}

#Create Pvt-Route-table
resource "aws_route_table" "db-pvt-route-1" {
  vpc_id = aws_vpc.dbvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.db-nat-1.id
  }

  tags = {
    Name = "db-pvt-rot-1"
  }
  depends_on = [aws_route_table.db-pub-route]

}

#Create Pvt-Route-table
resource "aws_route_table" "db-pvt-route-2" {
  vpc_id = aws_vpc.dbvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.db-nat-2.id
  }

  tags = {
    Name = "db-pvt-rot-2"
  }
  depends_on = [aws_route_table.db-pvt-route-1]
}
#Create Pvt-Route-table
resource "aws_route_table" "db-pvt-route-3" {
  vpc_id = aws_vpc.dbvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.db-nat-1.id
  }

  tags = {
    Name = "db-pvt-rot-3"
  }
  depends_on = [aws_route_table.db-pvt-route-2]
}

#Create Pvt-Route-table
resource "aws_route_table" "db-pvt-route-4" {
  vpc_id = aws_vpc.dbvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.db-nat-2.id
  }

  tags = {
    Name = "db-pvt-rot-4"
  }
  depends_on = [aws_route_table.db-pvt-route-3]
}
#subnets Associations
#pub-subnet-association
resource "aws_route_table_association" "db-pub-1" {
  subnet_id      = aws_subnet.db-pub-sub-1.id
  route_table_id = aws_route_table.db-pub-route.id
  depends_on = [aws_route_table.db-pvt-route-4]
}
#pvt subnet-association
resource "aws_route_table_association" "db-pvt-1" {
  subnet_id      = aws_subnet.db-pvt-sub-1.id
  route_table_id = aws_route_table.db-pvt-route-1.id
  depends_on = [aws_route_table_association.db-pub-1]
}



#subnets Associations
#pub-subnet-association
resource "aws_route_table_association" "db-pub-2" {
  subnet_id      = aws_subnet.db-pub-sub-2.id
  route_table_id = aws_route_table.db-pub-route.id
  depends_on = [aws_route_table_association.db-pvt-1]

}
#pvt subnet-association
resource "aws_route_table_association" "db-pvt-2" {
  subnet_id      = aws_subnet.db-pvt-sub-2.id
  route_table_id = aws_route_table.db-pvt-route-2.id
  depends_on = [aws_route_table_association.db-pub-2]
}
#pvt subnet-association
resource "aws_route_table_association" "db-pvt-3" {
  subnet_id      = aws_subnet.db-pvt-sub-3.id
  route_table_id = aws_route_table.db-pvt-route-3.id
  depends_on = [aws_route_table_association.db-pvt-2]
}
#pvt subnet-association
resource "aws_route_table_association" "db-pvt-4" {
  subnet_id      = aws_subnet.db-pvt-sub-4.id
  route_table_id = aws_route_table.db-pvt-route-4.id
  depends_on = [aws_route_table_association.db-pvt-3]
}

