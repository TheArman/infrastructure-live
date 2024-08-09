terraform {
  source = "git@github.com:thearmanv/infrastructure-modules.git//vpc?ref=vpc-v0.0.1"
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
  env             = include.env.locals.env
  azs             = ["eu-west-1a", "eu-west-1b"]
  vpc_cidr_block  = "10.0.0.0/16"
  private_subnets = ["10.0.0.0/21", "10.0.8.0/21"]
  public_subnets  = ["10.0.16.0/21", "10.0.24.0/21"]
  
  eks_name        = "the-arman-cluster"
  // private_subnet_tags = {
  //   "kubernetes.io/role/internal-elb"              = 1
  //   "kubernetes.io/cluster/dev-the-arman-cluster"  = "owned"
  // }

  // public_subnet_tags = {
  //   "kubernetes.io/role/elb"                      = 1
  //   "kubernetes.io/cluster/dev-the-arman-cluster" = "owned"
  // }
}