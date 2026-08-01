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
# This is to separate the two parts of the cluster, and to allow for different DNS records for the two parts. It may be the same domain. The specific subdomains is set later.
cloudflare_api_token      = "<api-token>"         # Cloudflare API Token for updating the DNS records (Zone.Zone.Read and Zone.DNS.Edit permissions required for the two following domains)
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
# For optimal performance, it is recommended to use the same region for all servers. If you want redundancy, use different regions for each group.
# Region 1 is used for challs nodes, scale nodes and loadbalancer.
# Possible values: fsn1, hel1, nbg1, ash, hil, sin - See https://docs.hetzner.com/cloud/general/locations/
region_1     = "nbg1"       # Region for group 1, challs nodes, scale nodes and loadbalancer
region_2     = "nbg1"       # Region for group 2
region_3     = "nbg1"       # Region for group 3
network_zone = "eu-central" # Hetzner network zone. Possible values: "eu-central", "us-east", "us-west", "ap-southeast". Regions must be within the network zone.

# Servers
# Server definitions are split into four groups: Control Plane, Agents, Challs and Scale. Control plane and agents has three groups each, while challs and scale is one group each.
# Each group can be scaled and defined independently, to allow for smooth transitions between different server types and sizes.
# Control planes are the servers that run the Kubernetes control plane, and are responsible for managing the cluster. 
# Agents are the servers that run the workloads, and scale is used to scale the cluster up or down dynamically.
# Challs are the servers that run the CTF challenges.
# Scale is automatically scaled agent nodes, which is handled by the cluster autoscaler. It is optional, and can be used to scale the cluster up or down dynamically if there is not enough resources in the cluster.
# Challs and scale nodes are placed in region_1, and are tainted to make normal resources prefer agent nodes, but allow scheduling on challs and scale nodes if needed.

# Server types. See https://www.hetzner.com/cloud
# Control plane nodes - Nodes that run the Kubernetes control plane components.
control_plane_type_1 = "cx23" # Control plane group 1
control_plane_type_2 = "cx23" # Control plane group 2
control_plane_type_3 = "cx23" # Control plane group 3
# Agent nodes - Nodes that run general workloads, excluding CTF challenges.
agent_type_1         = "cx33" # Agent group 1
agent_type_2         = "cx33" # Agent group 2
agent_type_3         = "cx33" # Agent group 3
# Challenge nodes - Nodes dedicated to running CTF challenges.
challs_type          = "cx33" # CTF challenge nodes
# Scale nodes - Nodes that are automatically scaled by the cluster autoscaler. These nodes are used to scale the cluster up or down dynamically.
scale_type           = "cx33" # Scale group

# Server count 
# Control plane nodes - Nodes that run the Kubernetes control plane components.
# Minimum of 1 control plane across all groups. 1 in each group is recommended for HA.
control_plane_count_1 = 1 # Number of control plane nodes in group 1
control_plane_count_2 = 1 # Number of control plane nodes in group 2
control_plane_count_3 = 1 # Number of control plane nodes in group 3
# Agent nodes - Nodes that run general workloads, excluding CTF challenges.
# Minimum of 1 agent across all groups. 1 in each group is recommended for HA.
agent_count_1 = 1 # Number of agent nodes in group 1
agent_count_2 = 1 # Number of agent nodes in group 2
agent_count_3 = 1 # Number of agent nodes in group 3
# Challenge nodes - Nodes dedicated to running CTF challenges. These nodes are tainted to only run challenge workloads.
challs_count = 1 # Number of challenge nodes.
# Scale nodes - Nodes that are automatically scaled by the cluster autoscaler. These nodes are used to scale the cluster up or down dynamically.
scale_max = 0 # Maximum number of scale nodes. Set to 0 to disable autoscaling.

load_balancer_type = "lb11" # Load balancer type, see https://www.hetzner.com/cloud/load-balancer

# Traefik ingress configuration
traefik_additional_ports = [] # List of additional ports to open on the load balancer. Each port is defined by a name, an internal port, and an external port. The name is used as `entryPoints` in IngressRouteTCP resources. External ports is exposed in the load balancer, while internal port being exposed port on the Traefik pods.
traefik_trusted_ips      = [] # List of additional Trusted IPs to pass to Traefik as CIDR notation. Loadbalancer IPs are automatically added to this list. If you want to add additional trusted IPs, enter them here as a list of strings.

# ----------------------
# Versions
# ----------------------
# Values are maintained in the variables.tf file.
# You can override these values by uncommenting and setting your own versions here.

# kube_hetzner_version = "2.21.0" # The version of the Kube-Hetzner module to use. More information at https://github.com/mysticaltech/terraform-hcloud-kube-hetzner
