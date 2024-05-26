module "infrastructure" {
  source = "./vpc"
  model_vpc_name   = var.vpc_name
  model_aws_region = var.aws_region
  model_sqs_name = var.sqs_name
}

module "eks" {
  source = "./eks"
  depends_on = [module.infrastructure]
  model_vpc_name   = var.vpc_name
  model_aws_region = var.aws_region
}

module "provision-helm-remote-charts" {
  source = "./helm/helm-remote"
  model_vpc_name       = var.vpc_name
  model_aws_region     = var.aws_region
  eks_cluster_oidc_arn = module.eks.eks_cluster_oidc_arn

  depends_on = [module.eks, module.infrastructure]
}

module "provision-helm-local-charts" {
  source = "./helm/helm-local"
  depends_on = [module.provision-helm-remote-charts]

  model_aws_region = var.aws_region
  model_sqs_name = var.sqs_name
}
