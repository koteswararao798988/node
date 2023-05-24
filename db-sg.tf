# creating security groups
resource "aws_security_group" "db-sg" {
  vpc_id = aws_vpc.dbvpc.id
  depends_on = [aws_route_table_association.db-pvt-4]
# inbound rules
# httpd access from anywhere
ingress {
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
# ssh access from anywhere
ingress {
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
ingress {
    from_port = 27017
    to_port = 27017
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}
# outbound rules
egress {
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}
}
