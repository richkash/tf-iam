module "dev_team" {
  source    = "../modules/iam-team"
  team_name = "developers"
  users     = ["dev_user1", "dev_user2"]
  env       = "dev"
}
