locals {
  instanced_challenges = var.challenges_instanced
  shared_challenges    = var.challenges_shared
  static_challenges    = var.challenges_static

  challenges_branch = var.challenges_branch == "" ? local.env_branch : var.challenges_branch

  challenge_repo_url = var.challenges_repository
  branch             = local.challenges_branch

  argocd_project_config    = "challenges-config"
  argocd_project_shared    = "challenges-shared"
  argocd_project_instanced = "challenges-instanced"

  config_namespace = "challenge-config"
}
