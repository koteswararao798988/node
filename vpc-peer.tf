# Create the VPC peering connection
resource "aws_vpc_peering_connection" "peering" {
  peer_vpc_id = aws_vpc.dbvpc.id
  vpc_id      = aws_vpc.mainvpc.id
  auto_accept = true
  depends_on  = [aws_security_group.db-sg]
}
resource "aws_route" "vpc_mainvpc_to_vpc_dabvpc" {
  route_table_id         = aws_route_table.pub-route.id
  destination_cidr_block = aws_vpc.dbvpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
  depends_on = [aws_vpc_peering_connection.peering]
}
resource "aws_route" "vpc_dbvpc_to_vpc_mainvpc" {
  route_table_id         = aws_route_table.db-pub-route.id
  destination_cidr_block = aws_vpc.mainvpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
  depends_on = [aws_route.vpc_mainvpc_to_vpc_dabvpc]
}



