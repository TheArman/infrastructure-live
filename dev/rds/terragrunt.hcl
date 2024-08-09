terraform {
  source = "git@github.com:thearmanv/infrastructure-modules.git//rds?ref=rds-v0.0.1"
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
  env                = include.env.locals.env
  rds_name           = "the-arman"
  rds_username       = "thearman"
  rds_db_name        = "bshotel"
  rds_engine_version = "8.0"
  rds_engine         = "mysql"
  instance_class     = "db.t3.micro"
  allocated_storage  = 24
  default_tag        = "terraform_aws_rds_secrets_manager"
  subnet_ids         = dependency.vpc.outputs.private_subnet_ids
  sgp                = dependency.vpc.outputs.sgp-id

}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    private_subnet_ids = ["subnet-1234", "subnet-5678"]
  }
}