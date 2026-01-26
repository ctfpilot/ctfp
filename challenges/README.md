# CTF Pilot's Kubernetes Challenges

> [!IMPORTANT]
> You are leaving the automated CTF Pilot setup and entering a more advanced manual setup.  
> This requires knowledge of Kubernetes, Terraform/OpenTofu, and cloud infrastructure management.  
> If you are not comfortable with these technologies, it is recommended to use the automated setup provided by CTF Pilot.  
> Learn more about the automated setup in the [CTFp main README](../README.md).

This directory contains deployment configuration for the challenges within the CTFp system.

## Pre-requisites

The following software needs to be installed on your local machine:

- [Terraform](https://www.terraform.io/downloads.html) / [OpenTofu](https://opentofu.org)
- [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) (For interacting with the Kubernetes cluster)

The following services are required, in order to deploy the services to the cluster:

- A Kubernetes cluster (Deployed using the [CTF Pilot's Kubernetes Cluster on Hetzner Cloud](../cluster/README.md) guide or other means)
- Correctly deployed [ArgoCD](https://argo-cd.readthedocs.io/) within the Kubernetes cluster.
- Correctly deployed [CTF Pilot's Kubernetes Platform](../platform/README.md) within the Kubernetes cluster.

> [!NOTE]
> The challenges has only been tested within the CTFp system.

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
tofu init -backend-config=../backend/generated/challenges.hcl
tofu apply --var-file tfvars/data.tfvars
```

### Destroying the challenges

To destroy the deployed challenges, run the following command:

```bash
tofu destroy --var-file tfvars/data.tfvars
```
