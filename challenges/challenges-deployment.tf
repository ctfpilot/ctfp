locals {
  categories_standard = keys(local.shared_challenges)
  categories_isolated = keys(local.instanced_challenges)
  categories_config   = keys(local.static_challenges)
}

module "argocd_project_shared" {
  source = "../tf-modules/argocd/project"

  argocd_namespace = var.argocd_namespace
  project_name     = local.argocd_project_shared
  project_destinations = [
    {
      namespace = module.kube_ctf.namespace_standard_challenges
      server    = "*"
    }
  ]

  depends_on = [
    module.kube_ctf
  ]
}

module "argocd_project_instanced" {
  source = "../tf-modules/argocd/project"

  argocd_namespace = var.argocd_namespace
  project_name     = local.argocd_project_instanced
  project_destinations = [
    {
      namespace = module.kube_ctf.namespace_instanced_challenges
      server    = "*"
    }
  ]

  depends_on = [
    module.kube_ctf
  ]
}

module "argocd_project_static" {
  source = "../tf-modules/argocd/project"

  argocd_namespace = var.argocd_namespace
  project_name     = local.argocd_project_static
  project_destinations = [
    {
      namespace = local.config_namespace
      server    = "*"
    }
  ]

  depends_on = [
    module.kube_ctf
  ]
}

module "repo_access_standard" {
  source = "../tf-modules/private-repo"

  name             = local.argocd_project_shared
  argocd_namespace = var.argocd_namespace
  ghcr_username    = var.ghcr_username
  git_token        = var.git_token
  git_repo         = local.challenge_repo_url
  argocd_project   = local.argocd_project_shared

  depends_on = [
    module.kube_ctf,
    module.argocd_project_shared
  ]
}

module "repo_access_isolated" {
  source = "../tf-modules/private-repo"

  name             = local.argocd_project_instanced
  argocd_namespace = var.argocd_namespace
  ghcr_username    = var.ghcr_username
  git_token        = var.git_token
  git_repo         = local.challenge_repo_url
  argocd_project   = local.argocd_project_instanced

  depends_on = [
    module.kube_ctf,
    module.argocd_project_instanced
  ]
}

module "repo_access_config" {
  source = "../tf-modules/private-repo"

  name             = local.argocd_project_static
  argocd_namespace = var.argocd_namespace
  ghcr_username    = var.ghcr_username
  git_token        = var.git_token
  git_repo         = local.challenge_repo_url
  argocd_project   = local.argocd_project_static

  depends_on = [
    module.kube_ctf,
    module.argocd_project_static
  ]
}

module "shared_challenges" {
  source = "./challenges"

  for_each = toset(local.categories_standard)

  revision   = local.branch
  category   = each.key
  challenges = local.shared_challenges[each.key]

  config_only           = false
  argocd_project        = local.argocd_project_shared
  argocd_config_project = local.argocd_project_static
  argocd_namespace      = var.argocd_namespace
  application_repo_url  = local.challenge_repo_url
  challenge_namespace   = module.kube_ctf.namespace_standard_challenges
  config_namespace      = local.config_namespace
  helm = {
    valuesObject = {
      kubectf = {
        host = "challs.${var.cluster_dns_ctf}"
      }
    }
  }

  depends_on = [
    module.kube_ctf,
    module.argocd_project_static,
    module.argocd_project_shared,
    module.repo_access_standard
  ]
}

module "instanced_challenges" {
  source = "./challenges"

  for_each = toset(local.categories_isolated)

  revision   = local.branch
  category   = each.key
  challenges = local.instanced_challenges[each.key]

  config_only           = false
  argocd_project        = local.argocd_project_instanced
  argocd_config_project = local.argocd_project_static
  argocd_namespace      = var.argocd_namespace
  application_repo_url  = local.challenge_repo_url
  challenge_namespace   = module.kube_ctf.namespace_instanced_challenges
  config_namespace      = local.config_namespace
  helm = {
    valuesObject = {
      kubectf = {
        host = "challs.${var.cluster_dns_ctf}"
      }
    }
  }
  config_helm_only = true

  depends_on = [
    module.kube_ctf,
    module.argocd_project_static,
    module.argocd_project_instanced,
    module.repo_access_isolated
  ]
}

module "static_challenges" {
  source = "./challenges"

  for_each = toset(local.categories_config)

  revision   = local.branch
  category   = each.key
  challenges = local.static_challenges[each.key]

  config_only           = true
  argocd_project        = local.argocd_project_static
  argocd_config_project = local.argocd_project_static
  argocd_namespace      = var.argocd_namespace
  application_repo_url  = local.challenge_repo_url
  challenge_namespace   = local.config_namespace
  config_namespace      = local.config_namespace
  helm = {
    valuesObject = {
      kubectf = {
        host = "challs.${var.cluster_dns_ctf}"
      }
    }
  }

  depends_on = [
    module.kube_ctf,
    module.argocd_project_static,
    module.repo_access_config
  ]
}
