# CTF Pilot's Kubernetes Operations (Ops)

> [!IMPORTANT]
> You are leaving the automated CTF Pilot setup and entering a more advanced manual setup.  
> This requires knowledge of Kubernetes, Terraform/OpenTofu, and cloud infrastructure management.  
> If you are not comfortable with these technologies, it is recommended to use the automated setup provided by CTF Pilot.  
> Learn more about the automated setup in the [CTF Pilot's CTF Platform main README](../README.md).

This directory contains various operational applications, services and configurations, deployed as a base on top of the Kubernetes cluster.

Ops contians elements, that needs to be properly configured and deployed, before the CTF Platform can be correctly deployed within the cluster.

The following applications/services are included in the Ops:

- [ArgoCD](https://argo-cd.readthedocs.io/) - GitOps continuous delivery tool, used to deploy and manage applications within the Kubernetes cluster.

## Pre-requisites

The following software needs to be installed on your local machine:

- [Terraform](https://www.terraform.io/downloads.html) / [OpenTofu](https://opentofu.org)
- [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) (For interacting with the Kubernetes cluster)

The following services are required, in order to deploy the Kubernetes cluster:

- A Kubernetes cluster (Deployed using the [CTF Pilot's Kubernetes Cluster on Hetzner Cloud](../cluster/README.md) guide or other means)
- [Cloudflare](https://www.cloudflare.com/) account
- [Cloudflare API Token](https://dash.cloudflare.com/profile/api-tokens) (For authenticating with the Cloudflare API)
- [Cloudflare controlled domain](https://dash.cloudflare.com/) (For allowing the system to do DNS challenges for TLS certificates)

## Setup

Copy the `tfvars/template.tfvars` file to `tfvars/data.tfvars` and edit the file with your own values.  
The [`tfvars/template.tfvars`](tfvars/template.tfvars) file contains further information on each variable.

> [!IMPORTANT]
> Make sure you generate the backend configuration file before creating the cluster.  
> See the [backend generation instructions](../backend/README.md) for more information.
>
> You will also need to set the following environment variables for authentication to the S3 backend:
> - `AWS_ACCESS_KEY_ID`
> - `AWS_SECRET_ACCESS_KEY`
>
> See [OpenTofub backend S3 configuration](https://opentofu.org/docs/language/settings/backends/s3/) for more information.

Run the following command to apply the ressources to the Kubernetes cluster:

```bash
tofu init -backend-config=../backend/generated/cluster.hcl
tofu apply --var-file tfvars/data.tfvars
```

### Destroying the Ops

To destroy the deployed ops, run the following command:

```bash
tofu destroy --var-file tfvars/data.tfvars
```
