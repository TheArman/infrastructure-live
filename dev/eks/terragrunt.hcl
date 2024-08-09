terraform {
  source = "git@github.com:thearmanv/infrastructure-modules.git//eks?ref=eks-v0.0.1"
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
  eks_version = "1.30"
  env         = include.env.locals.env
  eks_name    = "the-arman-cluster"
  subnet_ids  = dependency.vpc.outputs.private_subnet_ids

  node_groups = {
    general = {
      capacity_type  = "SPOT"
      // capacity_type  = "ON_DEMAND"
      instance_types = ["t3.medium"]
      // instance_types = ["t3.large"]
      scaling_config = {
        desired_size = 1
        max_size     = 10
        min_size     = 0
      }
    }
  }
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    private_subnet_ids = ["subnet-1234", "subnet-5678"]
  }
}