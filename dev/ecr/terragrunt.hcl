terraform {
  source = "git@github.com:thearmanv/infrastructure-modules.git//ecr?ref=ecr-v0.0.1"
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
  env      = include.env.locals.env
  ecr_name = "the-arman"
}