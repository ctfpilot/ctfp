locals {
  pages = var.pages
  page_project = "ctfd-pages"
  pages_repo   = var.pages_repository
  pages_branch = var.pages_branch == "" ? local.env_branch : var.pages_branch
}

module "argocd_project_pages" {
  source = "../tf-modules/argocd/project"

  argocd_namespace = var.argocd_namespace
  project_name     = local.page_project
  project_destinations = [
    {
      namespace = kubernetes_namespace_v1.challenge-config.metadata[0].name
      server    = "*"
    }
  ]

  depends_on = [
    kubernetes_namespace_v1.challenge-config,
	null_resource.configure-ctfd
  ]
}

module "repo_access_config" {
  source = "../tf-modules/private-repo"

  name             = local.page_project
  argocd_namespace = var.argocd_namespace
  ghcr_username    = var.ghcr_username
  git_token        = var.git_token
  git_repo         = local.pages_repo
  argocd_project   = local.page_project

  depends_on = [
    kubernetes_namespace_v1.challenge-config,
    module.argocd_project_pages,
	null_resource.configure-ctfd
  ]
}

module "argocd-challenge-config" {
  for_each = toset(local.pages)

  source = "../tf-modules/argocd/application"

  argocd_namespace          = var.argocd_namespace
  application_namespace     = kubernetes_namespace_v1.challenge-config.metadata[0].name
  application_name          = "ctfd-page-${each.value}"
  application_repo_url      = local.pages_repo
  application_repo_path     = "pages/${each.value}/k8s"
  application_repo_revision = local.pages_branch
  application_project       = local.page_project

  argocd_labels = {
    "part-of"   = "ctfpilot"
    "component" = "ctfd-pages"
    # "version"   = local.branch
  }

  depends_on = [
    kubernetes_namespace_v1.challenge-config,
    module.argocd_project_pages,
    module.repo_access_config,
	null_resource.configure-ctfd
  ]
}
