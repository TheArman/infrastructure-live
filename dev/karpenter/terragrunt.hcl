terraform {
  source = "git@github.com:thearmanv/infrastructure-modules.git//karpenter?ref=karpenter-v0.0.1"
}

include "root" {
  path = find_in_parent_folders()
}

include "env" {
  path           = find_in_parent_folders("env.hcl")
  expose         = true
  merge_strategy = "no_merge"
}

inputs = {
  env = include.env.locals.env

  eks_id                   = dependency.eks.outputs.eks_id
  eks_name                 = dependency.eks.outputs.eks_name 
  eks_endpoint             = dependency.eks.outputs.eks_endpoint
  karpenter_name           = dependency.eks.outputs.karpenter_name
  karpenter_controller_arn = dependency.eks.outputs.karpenter_controller_arn
}

dependency "eks" {
  config_path = "../eks"
}

generate "helm_provider" {
  path      = "helm-provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
data "aws_eks_cluster" "eks" {
    name = var.eks_name
}

data "aws_eks_cluster_auth" "eks" {
    name = var.eks_name
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}
EOF
}