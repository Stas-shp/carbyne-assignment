data "aws_subnets" "carbyne-subnets" {
  tags = {
    Name = "private-subnet-*"
  }
}

resource "aws_eks_cluster" "carbyne_eks_cluster" {
  name     = "carbyne-cluster"
  role_arn = aws_iam_role.eks-cluster-role.arn
  version  = "1.26"

  vpc_config {
    subnet_ids = data.aws_subnets.carbyne-subnets.ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-cluster-policy
  ]
}

resource "aws_eks_node_group" "private-carbyne-nodes" {
  cluster_name    = aws_eks_cluster.carbyne_eks_cluster.name
  node_group_name = "private-carbyne-nodes"
  node_role_arn   = aws_iam_role.eks-nodes-role.arn

  subnet_ids = data.aws_subnets.carbyne-subnets.ids

  capacity_type  = "ON_DEMAND"
  instance_types = ["t3.medium"]

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 0
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "general"
  }

  launch_template {
    name    = aws_launch_template.eks-with-disks.name
    version = aws_launch_template.eks-with-disks.latest_version
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-node-policy,
    null_resource.kubectl
  ]
}

resource "aws_launch_template" "eks-with-disks" {
  name = "eks-with-disks"
  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 30
      volume_type = "gp3"
    }
  }
}

resource "null_resource" "kubectl" {
  triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = <<-EOT
      aws eks --region ${var.model_aws_region} update-kubeconfig --name 'carbyne-cluster' --kubeconfig ~/.kube/carbyne-cluster
    EOT
  }
  depends_on = [aws_eks_cluster.carbyne_eks_cluster]
}
