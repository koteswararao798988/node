resource "null_resource" "install_mongodb-1" {
  depends_on = [null_resource.export-pem]

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt install -y wget curl gnupg2 software-properties-common apt-transport-https ca-certificates lsb-release",
      "curl -fsSL https://www.mongodb.org/static/pgp/server-5.0.asc|sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/mongodb.gpg",
      "echo 'deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse' | sudo tee /etc/apt/sources.list.d/mongodb-org-5.0.list",
      "sudo apt update",
      "sudo apt install mongodb-org -y",
      "sudo apt-get install -y mongodb-org=5.0.9 mongodb-org-database=5.0.9 mongodb-org-server=5.0.9 mongodb-org-shell=5.0.9 mongodb-org-mongos=5.0.9 mongodb-org-tools=5.0.9",
      "echo 'mongodb-org hold' | sudo dpkg --set-selections",
      "echo 'mongodb-org-database hold' | sudo dpkg --set-selections",
      "echo 'mongodb-org-server hold' | sudo dpkg --set-selections",
      "echo 'mongodb-org-shell hold' | sudo dpkg --set-selections",
      "echo 'mongodb-org-mongos hold' | sudo dpkg --set-selections",
      "echo 'mongodb-org-tools hold' | sudo dpkg --set-selections",
      "sudo systemctl start mongod",
      "sudo systemctl enable mongod",
      "echo '${aws_instance.mongo-1.private_ip} mongod-primary' | sudo tee -a /etc/hosts",
      "echo '${aws_instance.mongo-2.private_ip} mongod-secondary' | sudo tee -a /etc/hosts",
      "echo '${aws_instance.mongo-3.private_ip} mongod-third' | sudo tee -a /etc/hosts",
      "sudo sed -i 's/^\\(\\s*bindIp:\\s*\\)127\\.0\\.0\\.1/\\1127.0.0.1,${aws_instance.mongo-1.private_ip}/' /etc/mongod.conf",
      "sudo sed -i '/^#replication:/a  replication:\\n   replSetName: rs1' /etc/mongod.conf",
      "sudo systemctl restart mongod",
      "sleep 20",
      "mongosh --eval 'rs.initiate()';",
      "sleep 20",
      "mongosh --eval 'rs.add(\"mongod-secondary\")';",
      "sleep 20",
      "mongosh --eval 'rs.add(\"mongod-third\")';"

    ]

   connection {
      type        = "ssh"
      user        = "ubuntu"
     private_key  = tls_private_key.rsa.private_key_pem 
      host        = aws_instance.mongo-1.private_ip
    bastion_host = aws_instance.bastion-host.public_ip
    }
  }
}

resource "null_resource" "install_mongodb-2" {
  depends_on = [null_resource.install_mongodb-1]

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt install -y wget curl gnupg2 software-properties-common apt-transport-https ca-certificates lsb-release",
      "curl -fsSL https://www.mongodb.org/static/pgp/server-5.0.asc|sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/mongodb.gpg",
      "echo 'deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse' | sudo tee /etc/apt/sources.list.d/mongodb-org-5.0.list",
      "sudo apt update",
      "sudo apt install mongodb-org -y",
      "sudo apt-get install -y mongodb-org=5.0.9 mongodb-org-database=5.0.9 mongodb-org-server=5.0.9 mongodb-org-shell=5.0.9 mongodb-org-mongos=5.0.9 mongodb-org-tools=5.0.9",
      "echo 'mongodb-org hold' | sudo dpkg --set-selections",
      "echo 'mongodb-org-database hold' | sudo dpkg --set-selections",
      "echo 'mongodb-org-server hold' | sudo dpkg --set-selections",
      "echo 'mongodb-org-shell hold' | sudo dpkg --set-selections",
      "echo 'mongodb-org-mongos hold' | sudo dpkg --set-selections",
      "echo 'mongodb-org-tools hold' | sudo dpkg --set-selections",
      "sudo systemctl start mongod",
      "sudo systemctl enable mongod",
      "echo '${aws_instance.mongo-1.private_ip} mongod-primary' | sudo tee -a /etc/hosts",
      "echo '${aws_instance.mongo-2.private_ip} mongod-secondary' | sudo tee -a /etc/hosts",
      "echo '${aws_instance.mongo-3.private_ip} mongod-third' | sudo tee -a /etc/hosts",
      "sudo sed -i 's/^\\(\\s*bindIp:\\s*\\)127\\.0\\.0\\.1/\\1127.0.0.1,${aws_instance.mongo-2.private_ip}/' /etc/mongod.conf",
      "sudo sed -i '/^#replication:/a  replication:\\n   replSetName: rs1' /etc/mongod.conf",
      "sudo systemctl restart mongod",

    ]

   connection {
      type        = "ssh"
      user        = "ubuntu"
     private_key  = tls_private_key.rsa.private_key_pem
      host        = aws_instance.mongo-2.private_ip
    bastion_host = aws_instance.bastion-host.public_ip
    }
  }
}

resource "null_resource" "install_mongodb-3" {
  depends_on = [null_resource.install_mongodb-2]

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt install -y wget curl gnupg2 software-properties-common apt-transport-https ca-certificates lsb-release",
      "curl -fsSL https://www.mongodb.org/static/pgp/server-5.0.asc|sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/mongodb.gpg",
      "echo 'deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse' | sudo tee /etc/apt/sources.list.d/mongodb-org-5.0.list",
      "sudo apt update",
      "sudo apt install mongodb-org -y",
      "sudo apt-get install -y mongodb-org=5.0.9 mongodb-org-database=5.0.9 mongodb-org-server=5.0.9 mongodb-org-shell=5.0.9 mongodb-org-mongos=5.0.9 mongodb-org-tools=5.0.9",
      "echo 'mongodb-org hold' | sudo dpkg --set-selections",
      "echo 'mongodb-org-database hold' | sudo dpkg --set-selections",
      "echo 'mongodb-org-server hold' | sudo dpkg --set-selections",
      "echo 'mongodb-org-shell hold' | sudo dpkg --set-selections",
      "echo 'mongodb-org-mongos hold' | sudo dpkg --set-selections",
      "echo 'mongodb-org-tools hold' | sudo dpkg --set-selections",
      "sudo systemctl start mongod",
      "sudo systemctl enable mongod",
      "echo '${aws_instance.mongo-1.private_ip} mongod-primary' | sudo tee -a /etc/hosts",
      "echo '${aws_instance.mongo-2.private_ip} mongod-secondary' | sudo tee -a /etc/hosts",
      "echo '${aws_instance.mongo-3.private_ip} mongod-third' | sudo tee -a /etc/hosts",
      "sudo sed -i 's/^\\(\\s*bindIp:\\s*\\)127\\.0\\.0\\.1/\\1127.0.0.1,${aws_instance.mongo-3.private_ip}/' /etc/mongod.conf",
      "sudo sed -i '/^#replication:/a  replication:\\n   replSetName: rs1' /etc/mongod.conf",
      "sudo systemctl restart mongod",

    ]

   connection {
      type        = "ssh"
      user        = "ubuntu"
     private_key  = tls_private_key.rsa.private_key_pem
      host        = aws_instance.mongo-3.private_ip
    bastion_host = aws_instance.bastion-host.public_ip
    }
  }
}

