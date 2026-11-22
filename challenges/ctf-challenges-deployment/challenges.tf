locals {
  categories_shared    = keys(var.challenges_shared)
  categories_instanced = keys(var.challenges_instanced)
}

module "argocd_project_shared" {
  source   = "../../tf-modules/argocd/project"

  argocd_namespace = var.argocd_namespace
  project_name     = var.argocd_project_shared_name
  project_destinations = [
    {
      namespace = var.kubectf_namespace_shared
      server    = "*"
    }
  ]
}

module "argocd_project_instanced" {
  source   = "../../tf-modules/argocd/project"

  argocd_namespace = var.argocd_namespace
  project_name     = var.argocd_project_instanced_name
  project_destinations = [
    {
      namespace = var.kubectf_namespace_instanced
      server    = "*"
    }
  ]
}

module "repo_access_shared" {
  source   = "../../tf-modules/private-repo"

  name             = var.argocd_project_shared_name
  argocd_namespace = var.argocd_namespace
  ghcr_username    = var.ghcr_username
  git_token        = var.git_token
  git_repo         = var.challenges_repository
  argocd_project   = var.argocd_project_shared_name

  depends_on = [
    module.argocd_project_shared
  ]
}

module "repo_access_instanced" {
  source   = "../../tf-modules/private-repo"

  name             = var.argocd_project_instanced_name
  argocd_namespace = var.argocd_namespace
  ghcr_username    = var.ghcr_username
  git_token        = var.git_token
  git_repo         = var.challenges_repository
  argocd_project   = var.argocd_project_instanced_name

  depends_on = [
    module.argocd_project_instanced
  ]
}

module "shared_challenges" {
  source = "../challenges"

  for_each = toset(local.categories_shared)

  revision   = var.challenges_branch
  category   = each.key
  challenges = var.challenges_shared[each.key]

  argocd_project       = var.argocd_project_shared_name
  argocd_namespace     = var.argocd_namespace
  application_repo_url = var.challenges_repository
  challenge_namespace  = var.kubectf_namespace_shared
  helm = {
    valuesObject = {
      kubectf = {
        host = "challs.${var.cluster_dns_ctf}"
      }
    }
  }

  depends_on = [
    module.argocd_project_shared,
    module.repo_access_shared
  ]
}

module "instanced_challenges" {
  source = "../challenges"

  for_each = toset(local.categories_instanced)

  revision   = var.challenges_branch
  category   = each.key
  challenges = var.challenges_instanced[each.key]

  argocd_project       = var.argocd_project_instanced_name
  argocd_namespace     = var.argocd_namespace
  application_repo_url = var.challenges_repository
  challenge_namespace  = var.kubectf_namespace_instanced

  depends_on = [
    module.argocd_project_instanced,
    module.repo_access_instanced
  ]
}
