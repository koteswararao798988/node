resource "aws_instance" "bastion-host" {
  ami           = "ami-0430580de6244e02e"  # Replace with your desired AMI ID
  instance_type = "t2.micro"      # Replace with your desired instance type
  key_name      = aws_key_pair.main_key_pair.key_name
  vpc_security_group_ids = [aws_security_group.db-sg.id]  # Replace with the desired security group ID(s)
  subnet_id              = aws_subnet.db-pub-sub-1.id  # Replace with the desired subnet ID

  tags = {
    Name = "Bastion-host"
  }
  depends_on = [aws_instance.app1]
}

resource "aws_instance" "mongo-1" {
  ami           = "ami-0430580de6244e02e"  # Replace with your desired AMI ID
  instance_type = "t2.micro"      # Replace with your desired instance type
  key_name      = aws_key_pair.main_key_pair.key_name 

  vpc_security_group_ids = [aws_security_group.db-sg.id]  # Replace with the desired security group ID(s)
  subnet_id              = aws_subnet.db-pvt-sub-1.id  # Replace with the desired subnet ID

  depends_on = [aws_instance.bastion-host]
  tags = {
    Name = "mongo-1"
  }
}
resource "aws_instance" "mongo-2" {
  ami           = "ami-0430580de6244e02e"  # Replace with your desired AMI ID
  instance_type = "t2.micro"      # Replace with your desired instance type
  key_name      = aws_key_pair.main_key_pair.key_name

  vpc_security_group_ids = [aws_security_group.db-sg.id]  # Replace with the desired security group ID(s)
  subnet_id              = aws_subnet.db-pvt-sub-2.id  # Replace with the desired subnet ID

  depends_on = [aws_instance.mongo-1]
  tags = {
    Name = "mongo-2"
  }
}
resource "aws_instance" "mongo-3" {
  ami           = "ami-0430580de6244e02e"  # Replace with your desired AMI ID
  instance_type = "t2.micro"      # Replace with your desired instance type
  key_name      = aws_key_pair.main_key_pair.key_name

  vpc_security_group_ids = [aws_security_group.db-sg.id]  # Replace with the desired security group ID(s)
  subnet_id              = aws_subnet.db-pvt-sub-3.id  # Replace with the desired subnet ID

  depends_on = [aws_instance.mongo-2]
  tags = {
    Name = "mongo-3"
  }
}

resource "null_resource" "export-pem" {
  provisioner "local-exec" {
    command = <<-EOT
      scp -o "StrictHostKeyChecking=no" -i "main-key.pem" "main-key.pem" ubuntu@${aws_instance.bastion-host.public_ip}:~
    EOT
    working_dir = "./"
  }
  depends_on = [aws_instance.mongo-3]
}

