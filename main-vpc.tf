provider "aws" {
  access_key = "AKIA2WKDGKX6RBPEUOEB"
  secret_key = "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"
  region     = "us-east-2"
}

#Create the vpc
resource "aws_vpc" "mainvpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "mainvpc"
  }
}
#Creating IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.mainvpc.id
  tags = {

    Name = "main-igw"
  }
  depends_on = [aws_vpc.mainvpc]
}

#Creating pub-subnet1
resource "aws_subnet" "pub-sub-1" {
  vpc_id                  = aws_vpc.mainvpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = "true"
  tags = {

    Name = "pub-subnet-1"
  }
  depends_on = [aws_internet_gateway.igw]
}
#Creating private subnet1
resource "aws_subnet" "pvt-sub-1" {
  vpc_id                  = aws_vpc.mainvpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "pvt-subnet-1"
  }
  depends_on = [aws_subnet.pub-sub-1]
}
#Creating pub-subnet2
resource "aws_subnet" "pub-sub-2" {
  vpc_id                  = aws_vpc.mainvpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-2b"
  map_public_ip_on_launch = "true"
  tags = {

    Name = "pub-subnet-2"
  }
  depends_on = [aws_subnet.pvt-sub-1]
}

#Creating pvt-subnet2
resource "aws_subnet" "pvt-sub-2" {
  vpc_id                  = aws_vpc.mainvpc.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "us-east-2b"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "pvt-subnet-2"
  }
  depends_on = [aws_subnet.pub-sub-2]
}

#Creating pvt-subnet3
resource "aws_subnet" "pvt-sub-3" {
  vpc_id                  = aws_vpc.mainvpc.id
  cidr_block              = "10.0.5.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "pvt-subnet-3"
  }
  depends_on = [aws_subnet.pvt-sub-2]
}

#Creating pvt-subnet4
resource "aws_subnet" "pvt-sub-4" {
  vpc_id                  = aws_vpc.mainvpc.id
  cidr_block              = "10.0.6.0/24"
  availability_zone       = "us-east-2b"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "pvt-subnet-4"
  }
  depends_on = [aws_subnet.pvt-sub-3]
}
#Create Pub-Route-table
resource "aws_route_table" "pub-route" {
  vpc_id = aws_vpc.mainvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id

  }
  tags = {
    Name = "pub-rot"
  }
  depends_on = [aws_subnet.pvt-sub-4]
}
#pub-subnet-association
resource "aws_route_table_association" "pub-1" {
  subnet_id      = aws_subnet.pub-sub-1.id
  route_table_id = aws_route_table.pub-route.id
  depends_on = [aws_route_table.pub-route]
}

#subnets Associations
#pub-subnet-association
resource "aws_route_table_association" "pub-2" {
  subnet_id      = aws_subnet.pub-sub-2.id
  route_table_id = aws_route_table.pub-route.id
  depends_on = [aws_route_table_association.pub-1]
}
