module "staging_team" {
  source    = "../modules/iam-team"
  team_name = "staging"
  users     = ["staging_user1", "staging_user2"]
  env       = "staging"
}
