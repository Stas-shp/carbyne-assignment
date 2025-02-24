data "tls_certificate" "eks-cert" {
  url = aws_eks_cluster.carbyne_eks_cluster.identity[0].oidc[0].issuer
}

data "aws_kms_key" "env-kms-key" {
  key_id = "alias/eks-encryption-key"
}

resource "aws_iam_openid_connect_provider" "eks-aws-iam-openid-connect-provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks-cert.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.carbyne_eks_cluster.identity[0].oidc[0].issuer
  tags = {
    Name = "eks-ca-oidc-provider"
  }
}

output "eks_cluster_oidc_arn" {
  value = aws_iam_openid_connect_provider.eks-aws-iam-openid-connect-provider.arn
}

resource "aws_iam_role" "eks-nodes-role" {
  name = "carbyne-node-role"
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

resource "aws_iam_role" "eks-cluster-role" {
  name = "carbyne-cluster-role"
  assume_role_policy = jsonencode({
    Statement : [{
      Action : "sts:AssumeRole"
      Effect : "Allow",
      Principal : {
        Service : "eks.amazonaws.com"
      },
    }]
    Version : "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "eks-node-policy" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonSQSReadOnlyAccess"
  ])
  role       = aws_iam_role.eks-nodes-role.name
  policy_arn = each.value
}

resource "aws_iam_role_policy_attachment" "eks-cluster-policy" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  ])
  role       = aws_iam_role.eks-cluster-role.name
  policy_arn = each.value
}