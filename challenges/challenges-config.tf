locals {
  instanced_challenges = var.challenges_instanced
  shared_challenges    = var.challenges_static
  static_challenges    = var.challenges_static

  challenges_branch = var.challenges_branch == "" ? local.env_branch : var.challenges_branch

  challenge_repo_url = var.challenges_repository
  branch             = local.challenges_branch

  argocd_project_instanced = "instanced-challenges"
  argocd_project_shared    = "shared-challenges"
  argocd_project_static    = "static-challenges"

  config_namespace = "challenge-config"
}
