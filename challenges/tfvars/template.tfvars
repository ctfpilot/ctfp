# ------------------------
# Deployment type
# ------------------------
# Deployment type represents the type of deployment to be used for the platform.
# It defines how many replicas of each service is deployed. It does not affect node deployment.
# You may overwrite the number of replicas for each service at the bottom of this file, but it is not recommended to do so unless you know what you are doing.
#
# Options:
# - "standard": Standard deployment with core services being deployed with 2 or more replicas, while some services are deployed with 1 replica. This is the recommended deployment type for production (minimum 2 control plane nodes, 2 agent nodes, 1 challs node).
# - "single-node": Single node deployment with all services being deployed with 1 replica, and HA being disabled where possible, this is the recommended deployment type for small clusters (1 control plane node, 1 agent node, 1 challs node). This is not recommended for production.
# - "ha": High availability deployment with all services being deployed with 2 or more replicas, and HA enabled where possible. This is the recommended deployment type for large-scale events that require high availability and redundancy. Requires a minimum of 3 control plane nodes, 3 agent nodes and 1 challs node.
deployment_type = "standard" # Deployment type for the cluster. Options: "standard", "single-node", "ha"

# ------------------------
# Kubernetes variables
# ------------------------
kubeconfig = "AA==" # Base64 encoded kubeconfig file

# ------------------------
# Generic information
# ------------------------
environment            = "test"  # Environment name for the CTF
cluster_dns_management = "<dns>" # The specific domain name to use for the DNS records for the management part of the cluster
cluster_dns_ctf        = "<dns>" # The domain name to use for the DNS records for the CTF part of the cluster

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
