resource "aws_iam_role" "eks-iam-role-2" {
 name = "kubernetes-eks-iam-role-2"
 depends_on = [null_resource.copy]
 path = "/"

 assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
  {
   "Effect": "Allow",
   "Principal": {
    "Service": "eks.amazonaws.com"
   },
   "Action": "sts:AssumeRole"
  }
 ]
}
EOF

}
resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
 policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
 role    = aws_iam_role.eks-iam-role-2.name
}
resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly-EKS" {
 policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
 role    = aws_iam_role.eks-iam-role-2.name
}

resource "aws_eks_cluster" "kubernetes-eks" {
 name = "k8s-cluster"
 role_arn = aws_iam_role.eks-iam-role-2.arn
 vpc_config {
  subnet_ids = [aws_subnet.pub-sub-1.id, aws_subnet.pub-sub-2.id]
}

 depends_on = [
  aws_iam_role.eks-iam-role-2,
 ]
}

resource "aws_iam_role" "workernodes-2" {
  name = "eks-node-group-example-2"

  assume_role_policy = jsonencode({
   Statement = [{
    Action = "sts:AssumeRole"
    Effect = "Allow"
    Principal = {
     Service = "ec2.amazonaws.com"
    }
   }]
   Version = "2012-10-17"
  })
 }
 resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role    = aws_iam_role.workernodes-2.name
 }

 resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role    = aws_iam_role.workernodes-2.name
 }

 resource "aws_iam_role_policy_attachment" "EC2InstanceProfileForImageBuilderECRContainerBuilds" {
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds"
  role    = aws_iam_role.workernodes-2.name
 }

 resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role    = aws_iam_role.workernodes-2.name
}

resource "aws_eks_node_group" "worker-node-group-1" {
  cluster_name  = aws_eks_cluster.kubernetes-eks.name
  node_group_name = "eks-workernodes-2"
  node_role_arn  = aws_iam_role.workernodes-2.arn
  subnet_ids   = [aws_subnet.pub-sub-1.id, aws_subnet.pub-sub-2.id]
  instance_types = ["t2.micro"]
  scaling_config {
   desired_size = 2
   max_size   = 3
   min_size   = 2
  }

  depends_on = [
   aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
   aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
   #aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}

