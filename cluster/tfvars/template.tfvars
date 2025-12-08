# ------------------------
# Hetzner
# ------------------------
hcloud_token = "<hetzner-token>" # Hetzner cloud project token (obtained from a specific project in Hetzner cloud)

# ------------------------
# SSH
# ------------------------
# The following tokens are base64 encoded public and private keys.
# To generate these, leave the template as is, and run the following commands to fill in the values:
# $ python3 cli.py generate-keys --insert
ssh_key_private_base64 = "<private_key>" # The private key to use for SSH access to the servers (base64 encoded)
ssh_key_public_base64  = "<public_key>"  # The public key to use for SSH access to the servers (base64 encoded)


# ------------------------
# Cloudflare variables
# ------------------------
# The cluster uses two domains for the management and CTF parts of the cluster.
# This is to sepearte the two parts of the cluster, and to allow for different DNS records for the two parts. It may be the same domain. The specific subdomains is set later.
cloudflare_api_token      = "<api-token>"         # Cloudflare API Token for updating the DNS records (Zne.Zone.Read and Zone.DNS.Edit permissions required for the two following domains)
cloudflare_dns_management = "<management-domain>" # The top level domain (TLD) to use for the DNS records for the management part of the cluster
cloudflare_dns_platform   = "<platform-domain>"   # The top level domain (TLD) to use for the DNS records for the platform part of the cluster
cloudflare_dns_ctf        = "<ctf-domain>"        # The top level domain (TLD) to use for the DNS records for the CTF part of the cluster

# ------------------------
# DNS information
# ------------------------
# The cluster uses two domains for the management and CTF parts of the cluster.
# The following is the actually used subdomains for the two parts of the cluster. They may be either TLD or subdomains.
cluster_dns_management = "<dns-management-domain>" # The specific domain name to use for the DNS records for the management part of the cluster. Must be the TLD or subdomain of `cloudflare_dns_management`
cluster_dns_platform   = "<dns-platform-domain>"   # The domain name to use for the DNS records for the platform part of the cluster. Must be the TLD or subdomain of `cloudflare_dns_platform`
cluster_dns_ctf        = "<dns-ctf-domain>"        # The domain name to use for the DNS records for the CTF challenges part of the cluster. Must be the TLD or subdomain of `cloudflare_dns_ctf`

# ------------------------
# Cluster configuration
# ------------------------
# WARNING: Changing region while the cluster is running will cause all servers in the group to be destroyed and recreated.
# For uptimal performance, it is recommended to use the same region for all servers.
# Region 1 is used for scale nodes and loadbalancer.
# Possible values: fsn1, hel1, nbg1
region_1     = "fsn1"       # Region for subgroup 1
region_2     = "fsn1"       # Region for subgroup 2
region_3     = "fsn1"       # Region for subgroup 3
network_zone = "eu-central" # Hetzner network zone. Possible values: "eu-central", "us-east", "us-west", "ap-southeast". Regions must be within the network zone.

# Servers
# Server definitions are split into three groups: Control Plane, Agents, and Scale. Control plane and agents has three groups each, and scale has one group.
# Each group can be scaled and defined independently, to allow for smooth transitions between different server types and sizes.
# Control planes are the servers that run the Kubernetes control plane, and are responsible for managing the cluster. 
# Agents are the servers that run the workloads, and scale is used to scale the cluster up or down dynamically.
# Scale is automatically scaled agent nodes, which is handled by the cluster autoscaler. It is optional, and can be used to scale the cluster up or down dynamically.

# Server types (e.g., "cx32", "cx42", "cx22") See https://www.hetzner.com/cloud
control_plane_type_1 = "cx32" # Control plane group 1
control_plane_type_2 = "cx32" # Control plane group 2
control_plane_type_3 = "cx32" # Control plane group 3
agent_type_1         = "cx32" # Agent group 1
agent_type_2         = "cx32" # Agent group 2
agent_type_3         = "cx32" # Agent group 3
scale_type           = "cx32" # Scale group

# Server count 
# Minimum of 1 control plane across all groups. 1 in each group is recommended for HA.
control_plane_count_1 = 1 # Number of control plane nodes in group 1
control_plane_count_2 = 1 # Number of control plane nodes in group 2
control_plane_count_3 = 1 # Number of control plane nodes in group 3
# Minimum of 1 agent across all groups. 1 in each group is recommended for HA.
agent_count_1 = 1 # Number of agent nodes in group 1
agent_count_2 = 1 # Number of agent nodes in group 2
agent_count_3 = 1 # Number of agent nodes in group 3
# Challenge nodes - Nodes dedicated to running CTF challenges. These nodes are tainted to only run challenge workloads.
challs_count = 0 # Number of challenge nodes.
# Scale nodes - Nodes that are automatically scaled by the cluster autoscaler. These nodes are used to scale the cluster up or down dynamically.
scale_max = 0 # Maximum number of scale nodes. Set to 0 to disable autoscaling.

load_balancer_type = "lb11" # Load balancer type, see https://www.hetzner.com/cloud/load-balancer
