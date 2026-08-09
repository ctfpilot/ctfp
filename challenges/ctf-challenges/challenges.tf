locals {
  categories_config    = keys(var.challenges_static)
  categories_shared    = var.config_only ? [] : keys(var.challenges_shared)
  categories_instanced = var.config_only ? [] : keys(var.challenges_instanced)

  project_count = var.config_only ? [] : [""]
}

module "argocd_project_config" {
  source = "../../tf-modules/argocd/project"

  argocd_namespace = var.argocd_namespace
  project_name     = var.argocd_project_config_name
  project_destinations = [
    {
      namespace = var.config_namespace
      server    = "*"
    }
  ]
}

module "argocd_project_shared" {
  source   = "../../tf-modules/argocd/project"
  for_each = toset(local.project_count)

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
  for_each = toset(local.project_count)

  argocd_namespace = var.argocd_namespace
  project_name     = var.argocd_project_instanced_name
  project_destinations = [
    {
      namespace = var.kubectf_namespace_instanced
      server    = "*"
    }
  ]
}

module "repo_access_config" {
  source = "../../tf-modules/private-repo"

  name             = var.argocd_project_config_name
  argocd_namespace = var.argocd_namespace
  ghcr_username    = var.ghcr_username
  git_token        = var.git_token
  git_repo         = var.challenges_repository
  argocd_project   = var.argocd_project_config_name

  depends_on = [
    module.argocd_project_config
  ]
}

module "repo_access_shared" {
  source   = "../../tf-modules/private-repo"
  for_each = toset(local.project_count)

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
  for_each = toset(local.project_count)

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

module "config_challenges-static" {
  source = "../configs"

  for_each = toset(keys(var.challenges_static))

  ctf        = var.ctf
  revision   = var.challenges_branch
  category   = each.key
  challenges = var.challenges_static[each.key]

  argocd_project       = var.argocd_project_config_name
  argocd_namespace     = var.argocd_namespace
  application_repo_url = var.challenges_repository
  config_namespace     = var.config_namespace
  helm = {
    valuesObject = {
      kubectf = {
        host = "challs.${var.cluster_dns_ctf}"
      }
    }
  }

  depends_on = [
    module.argocd_project_config,
    module.repo_access_config
  ]
}

module "config_challenges-shared" {
  source = "../configs"

  for_each = toset(keys(var.challenges_shared))

  ctf        = var.ctf
  revision   = var.challenges_branch
  category   = each.key
  challenges = var.challenges_shared[each.key]

  argocd_project       = var.argocd_project_config_name
  argocd_namespace     = var.argocd_namespace
  application_repo_url = var.challenges_repository
  config_namespace     = var.config_namespace
  helm = {
    valuesObject = {
      kubectf = {
        host = "challs.${var.cluster_dns_ctf}"
      }
    }
  }

  depends_on = [
    module.argocd_project_config,
    module.repo_access_config
  ]
}

module "config_challenges-instanced" {
  source = "../configs"

  for_each = toset(keys(var.challenges_instanced))

  ctf        = var.ctf
  revision   = var.challenges_branch
  category   = each.key
  challenges = var.challenges_instanced[each.key]

  argocd_project       = var.argocd_project_config_name
  argocd_namespace     = var.argocd_namespace
  application_repo_url = var.challenges_repository
  config_namespace     = var.config_namespace
  helm = {
    valuesObject = {
      kubectf = {
        host = "challs.${var.cluster_dns_ctf}"
      }
    }
  }

  depends_on = [
    module.argocd_project_config,
    module.repo_access_config
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
  config_namespace     = var.config_namespace
  helm = {
    valuesObject = {
      kubectf = {
        host = "challs.${var.cluster_dns_ctf}"
      }
    }
  }

  depends_on = [
    module.argocd_project_config,
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
  config_namespace     = var.config_namespace

  depends_on = [
    module.argocd_project_config,
    module.argocd_project_instanced,
    module.repo_access_instanced
  ]
}
