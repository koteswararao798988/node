resource "null_resource" "install_kubectl" {
  provisioner "local-exec" {
    command = <<-EOT
      sudo apt-get update
      sudo apt-get install unzip
      curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
      unzip awscliv2.zip
      sudo ./aws/install
       curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
      chmod +x ./kubectl
      sudo mv ./kubectl /usr/local/bin/kubectl
      aws configure set aws_access_key_id "AKIA2WKDGKX6RBPEUOEB"
      aws configure set aws_secret_access_key "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"
      aws configure set region "us-east-2"
      aws eks --region us-east-2 update-kubeconfig --name ${aws_eks_cluster.kubernetes-eks.name}
    EOT
  }

  depends_on = [aws_eks_node_group.worker-node-group-1]  
}
#resource "local_file" "kubeconfig" {
 # content  = "/root/.kube/config"  # Replace with the variable representing the path to your .kubeconfig file
 # filename = "/home/ubuntu/.kube/config"  # Desired path for the .kubeconfig file
#}
