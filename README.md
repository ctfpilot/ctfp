# CTFp - CTF Pilot's CTF Platform

> [!TIP]
> If you are looking for **how to build challenges for CTFp**, please check out the **[CTF Pilot's Challenges Template](https://github.com/ctfpilot/challenges-template)** and **[CTF Pilot's Challenge Toolkit](https://github.com/ctfpilot/challenge-toolkit)** repositories.

CTFp (CTF Pilot's CTF Platform) is a CTF plaform designed to host large-scale Capture The Flag (CTF) competitions, with focus on scalability, resilience and ease of use.  
The platform uses Kubernetes as the underlying orchestration system, where both the management, scoreboard and challenge infrastructure are deployed as Kubernetes resources. It then leverages GitOps through [ArgoCD](https://argo-cd.readthedocs.io/en/stable/) for managing the platform's configuration and deployments, including the CTF challenges.

CTFp acts as the orchestration layer for deploying and managing the platform, while utilizing a varirety of CTF Pilots components for providing the full functionality of the platform.

CTFp provides a CLI tool for managing the deployment of the platform, but it is possible to use the individual Terraform components directly if desired. To further work with the platform after initial deployment, you will primarily interact with the Kubernetes cluster using `kubectl`, ArgoCD and the other monitoring systems deployed.

> [!IMPORTANT]
> In order to run CTFp properly, you will need to have a working knowledge of **Cloud**, **Kubernetes**, **Terraform/OpenTofu**, **GitOps** and **CTFd**.  
> The platform is designed to work with CTF Pilot's Challenges ecosystem, to ensure secure hosting of CTF challenges.
>
> This platform is not intended for beginners, and it is assumed that you have prior experience with these technologies and systems.  
> Incorrect handling of Kubernetes resources can lead to data loss, downtime and security vulnerabilities.  
> Incorrectly configured challenges may lead to security vulnerabilities or platform instability.

This platform deploys real world infrastructure, and will incur costs when deployed.

## Features

CTFp offers a wide range of features to facilitate the deployment and management of CTF competitions. Below is an overview of the key features:

- **Infrastructure & Deployment**
  - **Multi-environment support** with isolated configurations for Test, Dev, and Production
  - **Component-based architecture** with four deployable components: Cluster, Ops, Platform, and Challenges
  - **Infrastructure as Code** using Terraform/OpenTofu with automated state management and S3 backend
  - **Multi-region Kubernetes clusters** on Hetzner Cloud with configurable node types and auto-scaling
  - **Custom server images** generation using Packer
  - **Cloudflare DNS integration** for management, platform, and CTF zones
- **Operations & Monitoring**
  - **GitOps workflow** powered by ArgoCD for automated deployments
  - **Comprehensive monitoring** with Prometheus, Grafana, and metrics exporters
  - **Log aggregation** via Filebeat to Elasticsearch
  - **Traefik ingress controller** with SSL certificate management (cert-manager)
  - **Discord webhook notifications** for platform events
  - **Automated descheduling** for optimal resource distribution
- **Scoreboard**
  - **Customizable CTFd scoreboard deployment** allowing for bring-your-own CTFd configuration
  - **Auto deployment of CTFd configuration** providing a ready-to-use CTFd instance
  - **Flexible CTF settings** supporting a large portion of CTFd's configuration options
  - **S3 storage configuration** for challenge files and user uploads in CTFd
  - **Clustered database setup** with MariaDB operator and automated backups to S3
  - **Redis caching** with Redis operator for ease of use
  - **Automatic deployment of CTFd pages** from GitHub
- **Challenge Management**
  - **Full support for CTF Pilot's Challenges ecosystem**, including KubeCTF integration
  - **Support for three challenge deployment modes**: Isolated, Shared, and Instanced
  - **Git-based deployment** with branch-specific configurations
  - **IP whitelisting** for challenge access control
  - **Custom fallback pages** for errors and instancing states
- **CLI Tool**
  - **Simple command-line interface** for managing the deployment and lifecycle of the platform
  - **Modular commands** for initializing, deploying, destroying, and managing components
  - **Environment management** for handling multiple deployment environments (Test, Dev, Prod)
  - **State management** with automated backend configuration, with states stored in S3
  - **Plan generation and review** before applying changes
  - **Sub 20 minute deployment time** for the entire platform (excluding image generation)
  - **Fully configured through configuration files** for easy setup and management

## Quick start

> [!TIP]
> **This is a quick start guide for getting the platform up and running, and acts as a quick reference guide.**  
> If it is your first time working with CTFp, we recommend going through the full documentation for a more in-depth understanding of the platform and its components.

To use the CTFp CLI tool, you first need to clone the repository:

```bash
git clone https://github.com/ctfpilot/ctfp
cd ctfp
```

First you need to initialize the platform configuration for your desired environment (test, dev, prod):

```bash
./ctfp.py init
```

> [!NOTE]
> You can add `--test`, `--dev` or `--prod` to specify the environment you want to initialize.  
> The default environment is `test` (`--test`).

Next, you need to fill out the configuration located in the `automated.<env>.tfvars` file.

In order to deploy, ensure you have SSH keys created, and inserted into your configuration:

```bash
./ctfp.py generate-keys --insert
```

To create the server images used for the Kubernetes cluster nodes, run:

```bash
./ctfp.py generate-images
```

Finally, you can deploy the entire platform with:

```bash
./ctfp.py deploy all
```

To destroy the entire platform, run:

```bash
./ctfp.py destroy all
```

`all` can be replaced with any of the individual components: `cluster`, `ops`, `platform`, `challenges`.

To interact with the cluster, run the following command to configure your `kubectl` context:

```bash
source kubectl.sh [test|dev|prod]
```

*`source` is required to set the environment variables in your current shell session.*

## Pre-requisites

In order to even deploy the platform, the following software needs to be installed on your local machine:

- [OpenTofu](https://opentofu.org) (Alternative version of [Terraform](https://www.terraform.io/downloads.html))
- [Packer](https://developer.hashicorp.com/packer/tutorials/docker-get-started/get-started-install-cli#installing-packer) - For initial generation of server images
- [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) - For interacting with the Kubernetes cluster
- [hcloud cli tool](https://github.com/hetznercloud/cli) - For interacting with the Hetzner Cloud API (Recommended, otherwise use the web interface)
- SSH client - For connecting to the servers

And the following is required in order to deploy the platform:

- [Hetzner Cloud](https://www.hetzner.com/cloud) account with a Hetzner Cloud project
- [Hetzner Cloud API Token](https://console.hetzner.cloud/projects) - For authenticating with the Hetzner Cloud API
- [Hetzner S3 buckets](https://console.hetzner.cloud/projects) - For storing the Terraform state files, backups and challenge data. We recommend using 3 separate buckets with seperate access keys for security reasons
- [Cloudflare](https://www.cloudflare.com/) account
- [Cloudflare API Token](https://dash.cloudflare.com/profile/api-tokens) - For authenticating with the Cloudflare API
- [3 Cloudflare controlled domains](https://dash.cloudflare.com/) - For allowing the system to allocate a domain for the Kubernetes cluster. Used to allocate management, platform and challenge domains.

## Contributing

We welcome contributions of all kinds, from **code** and **documentation** to **bug reports** and **feedback**!

Please check the [Contribution Guidelines (`CONTRIBUTING.md`)](/CONTRIBUTING.md) for detailed guidelines on how to contribute.

CTFp is a dual-licensed project. To maintain the ability to distribute contributions across all our licensing models, **all code contributions require signing a Contributor License Agreement (CLA)**.

You can review **[the CLA here](https://github.com/ctfpilot/cla)**. CLA signing happens automatically when you create your first pull request.  
To administrate the CLA signing process, we are using **[CLA assistant lite](https://github.com/marketplace/actions/cla-assistant-lite)**.

*A copy of the CLA document is also included in this repository as [`CLA.md`](CLA.md).*  
*Signatures are stored in the [`cla` repository](https://github.com/ctfpilot/cla).*

## Background

CTF Pilot started as a CTF Platform project, originating in **[Brunnerne](https://github.com/brunnerne)**.

## License

CTFp is licensed under a dual license, the **PolyForm Noncommercial License 1.0.0** for non-commercial use, and a **Commercial License** for commercial use.
You can find the full license for non-commercial use in the **[LICENSE.md](LICENSE.md)** file.  
For commercial licensing, please contact **[The0Mikkel](https://github.com/The0Mikkel)**.

We encourage all modifications and contributions to be shared back with the community, for example through pull requests to this repository.  
We also encourage all derivative works to be publicly available under **PolyForm Noncommercial License 1.0.0**.  
At all times must the license terms be followed.

For information regarding how to contribute, see the [contributing](#contributing) section above.

CTF Pilot is owned and maintained by **[The0Mikkel](https://github.com/The0mikkel)**.  
Required Notice: Copyright Mikkel Albrechtsen (<https://themikkel.dk>)

## Code of Conduct

We expect all contributors to adhere to our [Code of Conduct](/CODE_OF_CONDUCT.md) to ensure a welcoming and inclusive environment for all.
