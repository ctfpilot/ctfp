locals {
  all_static_challenges = concat([var.challenges_static], [for ctf in var.ctfs : ctf.challenges.static != null ? ctf.challenges.static : {}])
  all_static_keys       = distinct(flatten([for m in local.all_static_challenges : keys(m)]))
  all_static_merged = {
    for k in local.all_static_keys :
    k => flatten([
      for m in local.all_static_challenges : lookup(m, k, [])
    ])
  }

  all_shared_challenges = concat([var.challenges_shared], [for ctf in var.ctfs : ctf.challenges.shared != null ? ctf.challenges.shared : {}])
  all_shared_keys       = distinct(flatten([for m in local.all_shared_challenges : keys(m)]))
  all_shared_merged = {
    for k in local.all_shared_keys :
    k => flatten([
      for m in local.all_shared_challenges : lookup(m, k, [])
    ])
  }

  all_instanced_challenges = concat([var.challenges_instanced], [for ctf in var.ctfs : ctf.challenges.instanced != null ? ctf.challenges.instanced : {}])
  all_instanced_keys       = distinct(flatten([for m in local.all_instanced_challenges : keys(m)]))
  all_instanced_merged = {
    for k in local.all_instanced_keys :
    k => flatten([
      for m in local.all_instanced_challenges : lookup(m, k, [])
    ])
  }

  
  ctfs_mapped = {
    for ctf in var.ctfs :
    ctf.slug => merge(
      ctf,
      {
        config_only          = ctf.slug != var.ctfs[0].slug,
        static_challenges    = merge({for k, v in local.all_static_merged : k => concat(var.challenges_static[k], lookup(ctf.challenges.static != null ? ctf.challenges.static : {}, k, []))}),
        shared_challenges    = merge({for k, v in local.all_shared_merged : k => concat(var.challenges_shared[k], lookup(ctf.challenges.shared != null ? ctf.challenges.shared : {}, k, []))}),
        instanced_challenges = merge({for k, v in local.all_instanced_merged : k => concat(var.challenges_instanced[k], lookup(ctf.challenges.instanced != null ? ctf.challenges.instanced : {}, k, []))})
      }
    )
  }
}

module "challenges" {
  source = "./ctf-challenges"

  for_each = toset(keys(local.ctfs_mapped))

  ctf                        = local.ctfs_mapped[each.key].slug
  config_only                = !local.ctfs_mapped[each.key].config_only
  cluster_dns_ctf            = var.cluster_dns_ctf
  ghcr_username              = var.ghcr_username
  git_token                  = var.git_token
  challenges_repository      = var.challenges_repository
  challenges_branch          = var.challenges_branch == "" ? local.env_branch : var.challenges_branch
  config_namespace           = "challenge-config-${local.ctfs_mapped[each.key].slug}"
  argocd_namespace           = var.argocd_namespace
  argocd_project_config_name = "${local.argocd_project_config}-${local.ctfs_mapped[each.key].slug}"
  challenges_static          = local.ctfs_mapped[each.key].static_challenges
  challenges_shared          = local.ctfs_mapped[each.key].shared_challenges
  challenges_instanced       = local.ctfs_mapped[each.key].instanced_challenges

  depends_on = [
    module.kube_ctf
  ]
}


module "challenges_deployment" {
  source = "./ctf-challenges-deployment"

  cluster_dns_ctf               = var.cluster_dns_ctf
  ghcr_username                 = var.ghcr_username
  git_token                     = var.git_token
  challenges_repository         = var.challenges_repository
  challenges_branch             = var.challenges_branch == "" ? local.env_branch : var.challenges_branch
  argocd_namespace              = var.argocd_namespace
  argocd_project_instanced_name = local.argocd_project_instanced
  argocd_project_shared_name    = local.argocd_project_shared
  challenges_shared             = local.all_shared_merged
  challenges_instanced          = local.all_instanced_merged
  kubectf_namespace_shared      = module.kube_ctf.namespace_standard_challenges
  kubectf_namespace_instanced   = module.kube_ctf.namespace_instanced_challenges

  depends_on = [
    module.kube_ctf
  ]
}
