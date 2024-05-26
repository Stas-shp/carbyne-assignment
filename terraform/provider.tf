# terraform {
#   backend "s3" {
#     bucket                  = "terraform-s3-state-123123"
#     key                     = "carbyne"
#     region                  = "eu-central-1"
#   }
# }

provider "aws" {
    region = var.aws_region
}

terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.13.1"
    }
  }
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/carbyne-cluster" # Path to your Kubernetes config file
  }
}

provider "kubernetes" {
  config_path = "~/.kube/carbyne-cluster"
}