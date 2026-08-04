locals {
  ctfs_mapped = {
    for ctf in var.ctfs :
    ctf.slug => merge(
      ctf,
      {
        config_only = ctf.slug != var.ctfs[0].slug
      }
    )
  }
}

module "challege_deployment" {
  source = "./ctf-challenges"

  for_each = toset(keys(local.ctfs_mapped))

  ctf                           = local.ctfs_mapped[each.key].slug
  config_only                   = !local.ctfs_mapped[each.key].config_only
  cluster_dns_ctf               = var.cluster_dns_ctf
  ghcr_username                 = var.ghcr_username
  git_token                     = var.git_token
  challenges_repository         = var.challenges_repository
  challenges_branch             = var.challenges_branch
  config_namespace              = "challenge-config-${local.ctfs_mapped[each.key].slug}"
  argocd_namespace              = var.argocd_namespace
  argocd_project_config_name    = "${local.argocd_project_config}-${local.ctfs_mapped[each.key].slug}"
  argocd_project_instanced_name = local.argocd_project_instanced
  argocd_project_shared_name    = local.argocd_project_shared
  challenges_static             = var.challenges_static
  challenges_shared             = var.challenges_shared
  challenges_instanced          = var.challenges_instanced
  kubectf_namespace_shared      = module.kube_ctf.namespace_standard_challenges
  kubectf_namespace_instanced   = module.kube_ctf.namespace_instanced_challenges

  # TODO: ctf-challenges deploys both config and challenges for all ctfs.
  # I need to figure out, if kube-ctf can handle multiple CTFd's deploying instances, or it will cause problems.
  # The issue here, is that the current solution tries to deploy kubectf template double in the same namespace.

  depends_on = [
    module.kube_ctf
  ]
}
