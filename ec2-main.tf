resource "aws_instance" "app1" {
  ami                    = "ami-0430580de6244e02e"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.main_key_pair.key_name
  subnet_id              = aws_subnet.pub-sub-2.id
  vpc_security_group_ids = ["${aws_security_group.sg.id}"]
  tags = {
    Name = "web"
  }
  depends_on = [aws_security_group_rule.ingress]
}
