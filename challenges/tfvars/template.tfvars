# ------------------------
# Kubernetes variables
# ------------------------
kubeconfig = "AA==" # Base64 encoded kubeconfig file

# ------------------------
# Generic information
# ------------------------
environment     = "test"  # Environment name for the CTF
cluster_dns_management = "<dns>" # The specific domain name to use for the DNS records for the management part of the cluster
cluster_dns_ctf = "<dns>" # The domain name to use for the DNS records for the CTF part of the cluster

# ------------------------
# GitHub variables
# ------------------------
ghcr_username = "<username>" # GitHub Container Registry username
ghcr_token    = "<token>"    # GitHub Container Registry token. This token is used to pull images from the GitHub Container Registry. Only let this token have registry read access
git_token     = "<token>"    # GitHub repo token. Only let this token have read access to the needed repositories.

# ----------------------
# CTF configuration
# ----------------------
kubectf_auth_secret      = "<secret>" # The secret to use for the authSecret in the CTF configuration
kubectf_container_secret = "<secret>" # The secret to use for the containerSecret in the CTF configuration

# ------------------------
# Challenges configuration
# ------------------------
chall_whitelist_ips = ["<ip1>", "<ip2>"] # List of IPs to whitelist for challenge access

challenges_static = {
  "<category>" = ["<challenge_slug1>", "<challenge_slug2>"],
} # List of static challenges to deploy. Needs to be the slugs of the challenges
challenges_shared = {
  "<category>" = ["<challenge_slug1>", "<challenge_slug2>"],
} # List of shared challenges to deploy. Needs to be the slugs of the challenges
challenges_instanced = {
  "<category>" = ["<challenge_slug1>", "<challenge_slug2>"],
} # List of instanced challenges to deploy. Needs to be the slugs of the challenges

challenges_repository = "<url>"    # URL of the Git repository containing the challenge definitions
challenges_branch     = "<branch>" # Branch of the Git repository to use for the challenge definitions. Leave empty for environment based branch (environment == prod ? main : develop)

# ----------------------
# Docker images
# ----------------------
# Values are maintained in the variables.tf file.
# You can override these values by uncommenting and setting your own images here.

# image_instancing_fallback = "ghcr.io/ctfpilot/instancing-fallback:1.0.2" # The docker image for the instancing fallback deployment. See https://github.com/ctfpilot/instancing-fallback
# image_kubectf             = "ghcr.io/ctfpilot/kube-ctf:1.0.1"            # The docker image for the kube-ctf deployment. See https://github.com/ctfpilot/kube-ctf
