terraform {
  source = "git@github.com:thearmanv/infrastructure-modules.git//argocd?ref=argocd-v0.0.1"
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
  env              = include.env.locals.env
  eks_name         = dependency.eks.outputs.eks_name 
  chart_version    = "7.1.3"
  github_name      = "the_github_name"
  github_token     = "the_github_token"
  
  app_values = [<<EOF
applications:
    - name: applications
      namespace: argocd
      finalizers:
      - resources-finalizer.argocd.argoproj.io
      project: default
      source:
        repoURL: "https://github.com/thearmanv/argocd.git"
        targetRevision: HEAD
        path: dev-bs/applications
      destination:
        server: https://kubernetes.default.svc
        namespace: argocd
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
EOF
]
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