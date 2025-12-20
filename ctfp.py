# CTFp CLI tool
# Licensed under PolyForm Noncommercial License 1.0.0. 
# See LICENSE file in the project root for full license information.
# This file must not be distributed without the LICENSE file.
# Required Notice: Copyright Mikkel Albrechtsen (<https://themikkel.dk>)

import os
import sys
import argparse
import time
import subprocess

# Terraform parser - https://github.com/amplify-education/python-hcl2
import hcl2

import backend.generate as backend_generate

AUTO_APPLY = True
ENVIRONMENTS = ["test", "dev", "prod"]
FLAVOR = "tofu" # Can be "terraform" or "tofu"

CLUSTER_TFVARS = [
    # Hetzner
    "hcloud_token", 
    
    # SSH
    "ssh_key_private_base64", 
    "ssh_key_public_base64", 
    
    # Cloudflare variables
    "cloudflare_api_token", 
    "cloudflare_dns_management", 
    "cloudflare_dns_platform",
    "cloudflare_dns_ctf", 
    
    # DNS information
    "cluster_dns_management", 
    "cluster_dns_platform",
    "cluster_dns_ctf",

    # Cluster configuration
    "region_1",
    "region_2",
    "region_3",
    "network_zone",
    "control_plane_type_1",
    "control_plane_type_2",
    "control_plane_type_3",
    "agent_type_1",
    "agent_type_2",
    "agent_type_3",
    "scale_type",
    "control_plane_count_1",
    "control_plane_count_2",
    "control_plane_count_3",
    "agent_count_1",
    "agent_count_2",
    "agent_count_3",
    "challs_count",
    "scale_max",
    "load_balancer_type",
    
    # Versions
    "kube_hetzner_version",
]
OPS_TFVARS = [
    # Generic information
    "email", 
    "discord_webhook_url",
    
    # Cloudflare variables
    "cloudflare_api_token", 
    "cloudflare_dns_management", 
    "cloudflare_dns_platform",
    "cloudflare_dns_ctf", 
    "cluster_dns_management", 
    
    # Filebeat configuration
    "filebeat_elasticsearch_host",
    "filebeat_elasticsearch_username",
    "filebeat_elasticsearch_password",
    
    # Prometheus configuration
    "prometheus_storage_size",
    
    # Management configuration
    "argocd_github_secret",
    "argocd_admin_password", 
    "grafana_admin_password",
    "traefik_basic_auth",
    
    # GitHub variables
    "ghcr_username",
    "ghcr_token",
    
    # Docker images
    "image_error_fallback",
    "image_filebeat",
    
    # Versions
    "argocd_version",
    "cert_manager_version",
    "descheduler_version",
    "mariadb_operator_version",
    "kube_prometheus_stack_version",
    "redis_operator_version",
]
PLATFORM_TFVARS = [
    # Generic information
    "cluster_dns_management", 
    "cluster_dns_platform",
    
    # GitHub variables    
    "ghcr_username",
    "ghcr_token",
    "git_token",

    # Filebeat configuration
    "filebeat_elasticsearch_host",
    "filebeat_elasticsearch_username",
    "filebeat_elasticsearch_password",
    
    # CTF configuration
    "kubectf_auth_secret",
    
    # DB configuration
    "db_root_password",
    "db_user",
    "db_password",
    # DB backup configuration
    "s3_bucket",
    "s3_region",
    "s3_endpoint",
    "s3_access_key",
    "s3_secret_key",
    
    # CTFd Manager configuration
    "ctfd_manager_password",
    "ctfd_manager_github_repo",
    "ctfd_manager_github_branch",
    
    # CTFd configuration
    "ctfd_secret_key",
    "ctf_name",
    "ctf_description",
    "ctf_start_time",
    "ctf_end_time",
    "ctf_user_mode",
    "ctf_challenge_visibility",
    "ctf_account_visibility",
    "ctf_score_visibility",
    "ctf_registration_visibility",
    "ctf_verify_emails",
    "ctf_team_size",
    "ctf_brackets",
    "ctf_theme",
    "ctf_admin_name",
    "ctf_admin_email",
    "ctf_admin_password",
    "ctf_registration_code",
    "ctf_mail_server",
    "ctf_mail_port",
    "ctf_mail_username",
    "ctf_mail_password",
    "ctf_mail_tls",
    "ctf_mail_from",
    "ctf_logo_path",
    "ctf_s3_bucket",
    "ctf_s3_region",
    "ctf_s3_endpoint",
    "ctf_s3_access_key",
    "ctf_s3_secret_key",
    "ctf_s3_prefix",
    "ctfd_plugin_first_blood_limit_url",
    "ctfd_plugin_first_blood_limit",
    "ctfd_plugin_first_blood_message",
    "pages",
    "pages_repository",
    "pages_branch",
    "ctfd_k8s_deployment_repository",
    "ctfd_k8s_deployment_path",
    "ctfd_k8s_deployment_branch",
    
    # Docker images
    "image_ctfd_manager",
    "image_error_fallback",
    "image_filebeat",
    "image_ctfd_exporter",
    
    # Versions
    "mariadb_version",
]
CHALLENGES_TFVARS = [
    # Generic information
    "cluster_dns_management",
    "cluster_dns_ctf",
    
    # GitHub variables
    "ghcr_username",
    "ghcr_token",
    "git_token",
    
    # CTF configuration
    "kubectf_auth_secret",
    "kubectf_container_secret",
    
    # Challenges configuration
    "chall_whitelist_ips",
    "challenges_static",
    "challenges_shared",
    "challenges_instanced",
    "challenges_repository",
    "challenges_branch",
        
    # Docker images
    "image_instancing_fallback",
    "image_kubectf",
]

PATH = os.path.dirname(os.path.realpath(__file__))

class Logger:
    RED = "\033[91m"
    GREEN = "\033[92m"
    YELLOW = "\033[93m"
    BLUE = "\033[94m"
    RESET = "\033[0m"

    @staticmethod
    def error(message):
        print(f"{Logger.RED}Error: {message}{Logger.RESET}")
        exit(1)

    @staticmethod
    def info(message):
        print(f"{Logger.BLUE}Info: {message}{Logger.RESET}")
        
    @staticmethod
    def success(message):
        print(f"{Logger.GREEN}Success: {message}{Logger.RESET}")
        
    @staticmethod
    def warning(message):
        print(f"{Logger.YELLOW}Warning: {message}{Logger.RESET}")
        
    @staticmethod
    def debug(message):
        print(f"{Logger.BLUE}Debug: {message}{Logger.RESET}")
    
    @staticmethod
    def space():
        print("")


# Sanitize path
PATH = PATH.replace(" ", "\\ ").replace("\"", "\\\"").replace("'", "\\'")
# Check if PATH contains special characters
for char in ['&', ';', '$', '>', '<', '|', '`', '!', '*', '?', '(', ')', '[', ']', '{', '}', '~']:
    if char in PATH:
        Logger.error(f"Path to script contains special character '{char}'. Please move the script to a path without special characters")
        exit(1)

# Load env from .env
if os.path.exists(".env"):
    with open(".env", "r") as f:
        for line in f:
            if line.strip() and not line.startswith("#"):
                key, value = line.strip().split("=", 1)
                os.environ[key.strip()] = value.strip()

def run(cmd, shell=True):
    '''
    Run a subprocess in a new process group (where supported) and forward
    KeyboardInterrupt (SIGINT) to it. Returns the process returncode.
    '''
    import signal
    # Use os.setsid only on platforms where it is available (POSIX).
    preexec = os.setsid if hasattr(os, "setsid") else None
    proc = subprocess.Popen(
        cmd,
        shell=shell,
        preexec_fn=preexec
    )
    try:
        proc.wait()
    except KeyboardInterrupt:
        # On POSIX, if we created a new process group, send SIGINT to the group.
        if preexec is not None and hasattr(os, "killpg"):
            os.killpg(proc.pid, signal.SIGINT)
        else:
            # Fallback for non-POSIX: send SIGINT directly to the child.
            try:
                proc.send_signal(signal.SIGINT)
            except Exception:
                # As a last resort, terminate the process.
                proc.terminate()
        proc.wait()
    return proc.returncode

class Args:
    command = None
    parser = None
    
    def __init__(self):
        self.parser = argparse.ArgumentParser(description="CTFp CLI")

    def print_help(self):
        if self.parser is None:
            Logger.error("Parser is not initialized")
            exit(1)
        
        self.parser.print_help()

class Utils:    
    @staticmethod
    def extract_tuple_from_list(tuple_list, key):
        for item in tuple_list:
            if key in item:
                return item
        return None
    
class TFBackend:
    @staticmethod
    def get_backend_filename(component):
        return f"{component}.hcl"
    
    @staticmethod
    def get_backend_path(component):
        return f"{PATH}/backend/generated/{TFBackend.get_backend_filename(component)}"
    
    @staticmethod
    def backend_exists(component):        
        return os.path.exists(TFBackend.get_backend_path(component))

'''
Subcommand pattern
'''
class Command:
    name = "Command"
    help = "Command"
    description = "Command"
    
    def __init__(self, subparser):
        self.subparser = subparser.add_parser(self.name, help=self.help, description=self.description)
        self.subparser.set_defaults(func=self.run)

    def register_subcommand(self):
        raise NotImplementedError

    def run(self, args):
        raise NotImplementedError

class GenerateImages(Command):
    name = "generate-images"
    help = "Generate server images"
    description = "Generate server images"
    
    def register_subcommand(self):
        # No arguments to register
        return
    
    def run(self, args):
        Logger.info("Generating server images")
        try:
            rc = run(f"cd \"{PATH}/cluster\" && tmp_script=$(mktemp) && curl -sSL -o \"${{tmp_script}}\" https://raw.githubusercontent.com/kube-hetzner/terraform-hcloud-kube-hetzner/master/scripts/create.sh && chmod +x \"${{tmp_script}}\" && \"${{tmp_script}}\" && rm \"${{tmp_script}}\"", shell=True)
            if rc != 0:
                raise Exception
        except:
            Logger.error("Failed to generate images")
        Logger.success("Images generated successfully")
    

'''
Initialize automated.tfvars with the template
'''
class InitializeTFVars(Command):
    name = "init"
    help = "Initialize automated.tfvars"
    description = "Initialize automated.tfvars"
    environment = "test"  # Default environment
    
    def register_subcommand(self):
        self.subparser.add_argument("--force", action="store_true", help="Force overwrite automated.tfvars")
        self.subparser.add_argument("--test", action="store_true", help="Work with TEST cluster (default)")
        self.subparser.add_argument("--dev", action="store_true", help="Work with DEV cluster")
        self.subparser.add_argument("--prod", action="store_true", help="Work with PROD cluster")
        return
    
    def run(self, args):
        if [args.test, args.dev, args.prod].count(True) > 1:
            Logger.error("Please specify only one environment: --test, --dev or --prod")
            exit(1)
            
        self.environment = "test"
        if args.dev:
            self.environment = "dev"
        elif args.prod:
            self.environment = "prod"

        Logger.info(f"Initializing {self.get_filename_tfvars()} (ENV: {self.environment})")
        template = f"{PATH}/template.automated.tfvars"
        destination = f"{PATH}/{self.get_filename_tfvars()}"

        # Check if destination file already exists
        if os.path.exists(destination) and not args.force:
            Logger.warning(f"{self.get_filename_tfvars()} already exists")
            
            # Ask user if they want to overwrite the file
            response = input("Do you want to overwrite the file? (y/N): ")
            if response.lower() != "y":
                Logger.info("Exiting")
                exit(0)
        
        # Clone the template to the destination
        try:
            os_output = os.system(f"cp {template} {destination}")
            if os_output != 0:
                raise Exception
        except:
            Logger.error(f"Failed to initialize {self.get_filename_tfvars()}")
        Logger.success(f"{self.get_filename_tfvars()} initialized successfully")
    
    def get_filename_tfvars(self):
        return TFVARS.get_filename_tfvars(self.environment)

'''
Generate RSA keys
'''
class GenerateKeys(Command):
    name = "generate-keys"
    help = "Generate RSA keys"
    description = "Generate RSA keys"
    environment = "test"  # Default environment

    def register_subcommand(self):
        self.subparser.add_argument("--insert", action="store_true", help="Insert keys into automated.tfvars")
        self.subparser.add_argument("--test", action="store_true", help="Work with TEST cluster (default)")
        self.subparser.add_argument("--dev", action="store_true", help="Work with DEV cluster")
        self.subparser.add_argument("--prod", action="store_true", help="Work with PROD cluster")
        return

    def run(self, args):
        if [args.test, args.dev, args.prod].count(True) > 1:
            Logger.error("Please specify only one environment: --test, --dev or --prod")
            exit(1)
            
        self.environment = "test"
        if args.dev:
            self.environment = "dev"
        elif args.prod:
            self.environment = "prod"
            
        Logger.info("Generating RSA keys")
        try:
            rc = run([f"\"{PATH}\"/data/keys/create.sh"], shell=True)
            if rc != 0:
                raise Exception
        except:
            Logger.error("Failed to generate keys")
        
        Logger.success("Keys generated successfully in data/keys/ using ed25519")
        Logger.info("Public key: data/keys/k8s.pub")
        Logger.info("Private key: data/keys/k8s")
        
        # Insert keys into automated.tfvars
        if args.insert:
            TFVARS.insert_keys(self.environment)
            Logger.success(f"Keys inserted successfully into {TFVARS.get_filename_tfvars(self.environment)}")

'''
Insert SSH keys into automated.tfvars
'''
class InsertKeys(Command):
    name = "insert-keys"
    help = "Insert SSH keys into automated.tfvars"
    description = "Insert SSH keys into automated.tfvars"
    
    def register_subcommand(self):
        self.subparser.add_argument("--test", action="store_true", help="Works with TEST cluster (default)")
        self.subparser.add_argument("--dev", action="store_true", help="Works with DEV cluster")
        self.subparser.add_argument("--prod", action="store_true", help="Works with PROD cluster")
        return
    
    def run(self, args):
        if [args.test, args.dev, args.prod].count(True) > 1:
            Logger.error("Please specify only one environment: --test, --dev or --prod")
            exit(1)
            
        self.environment = "test"
        if args.dev:
            self.environment = "dev"
        elif args.prod:
            self.environment = "prod"
            
        Logger.info(f"Inserting SSH keys into {TFVARS.get_filename_tfvars(self.environment)}")
        TFVARS.insert_keys(self.environment)
        Logger.success(f"Keys inserted successfully into {TFVARS.get_filename_tfvars(self.environment)}")

'''
Deploy the platform
'''
class Deploy(Command):
    name = "deploy"
    help = "Deploy the platform"
    description = "Deploy the platform"
    times = []
    environment = "test"  # Default environment

    def register_subcommand(self):
        # Only run listed parts of the deployment
        self.subparser.add_argument("--cluster", action="store_true", help="Deploy the cluster")
        self.subparser.add_argument("--ops", action="store_true", help="Deploy the ops")
        self.subparser.add_argument("--platform", action="store_true", help="Deploy the platform")
        self.subparser.add_argument("--challenges", action="store_true", help="Deploy the challenges")
        self.subparser.add_argument("--all", action="store_true", help="Deploy all parts of the platform")
        self.subparser.add_argument("--test", action="store_true", help="Deploy TEST cluster (default)")
        self.subparser.add_argument("--dev", action="store_true", help="Deploy DEV cluster")
        self.subparser.add_argument("--prod", action="store_true", help="Deploy PROD cluster")
        return

    def run(self, args):
        global AUTO_APPLY
        
        if not args.cluster and not args.ops and not args.platform and not args.challenges and not args.all:
            Logger.error("Please specify which part of the platform to deploy")
            exit(1)
            
        if args.all and (args.cluster or args.ops or args.platform or args.challenges):
            Logger.error("Please specify only --all or individual parts of the platform")
            exit(1)

        if [args.test, args.dev, args.prod].count(True) > 1:
            Logger.error("Please specify only one environment: --test, --dev or --prod")
            exit(1)
                        
        if args.prod:
            AUTO_APPLY = False  # Disable auto-apply for production environment
        
        deploy_all = args.all
        deploy_cluster = args.cluster or deploy_all
        deploy_ops = args.ops or deploy_all
        deploy_platform = args.platform or deploy_all
        deploy_challenges = args.challenges or deploy_all

        self.environment = "test"
        if args.dev:
            self.environment = "dev"
        elif args.prod:
            self.environment = "prod"

        self.times.append(("start", time.time()))
        Logger.info("Deploying " + (self.environment.upper() if self.environment != "test" else "TEST") + " environment")
        self.check_values()
        Logger.space()

        if deploy_cluster:        
            start_time = time.time()
            self.cluster_deploy()
            self.times.append(("cluster", start_time, time.time(), time.time() - start_time))
            Logger.space()
            Logger.info(f"Time taken: {str(round(self.times[-1][3], 2))} seconds")
            Logger.space()
        
        if deploy_ops:
            start_time = time.time()
            self.ops_deploy()
            self.times.append(("ops", start_time, time.time(), time.time() - start_time))
            Logger.space()
            Logger.info(f"Time taken: {str(round(self.times[-1][3], 2))} seconds")
            Logger.space()
        
        if deploy_platform:
            start_time = time.time()
            self.platform_deploy()
            self.times.append(("platform", start_time, time.time(), time.time() - start_time))
            Logger.space()
            Logger.info(f"Time taken: {str(round(self.times[-1][3], 2))} seconds")
            Logger.space()
        
        if deploy_challenges:
            start_time = time.time()
            self.challenges_deploy()
            self.times.append(("challenges", start_time, time.time(), time.time() - start_time))
            Logger.space()
            Logger.info(f"Time taken: {str(round(self.times[-1][3], 2))} seconds")
            Logger.space()
        
        Logger.success("Platform deployed")
        self.times.append(("end", time.time()))

        Logger.info(f"Time taken: {str(round(Utils.extract_tuple_from_list(self.times, 'end')[1] - Utils.extract_tuple_from_list(self.times, 'start')[1], 2))} seconds")
        
        if deploy_cluster:
            Logger.info(f"Cluster time: {str(round(Utils.extract_tuple_from_list(self.times, 'cluster')[3], 2))} seconds")
        if deploy_ops:
            Logger.info(f"Ops time: {str(round(Utils.extract_tuple_from_list(self.times, 'ops')[3], 2))} seconds")
        if deploy_platform:
            Logger.info(f"Platform time: {str(round(Utils.extract_tuple_from_list(self.times, 'platform')[3], 2))} seconds")
        if deploy_challenges:
            Logger.info(f"Challenges time: {str(round(Utils.extract_tuple_from_list(self.times, 'challenges')[3], 2))} seconds")
    
    '''
    Initialize Terraform to a given environment (workspace)
    '''
    def init_terraform(self, path, components: str = ""):
        Logger.info("Initializing Terraform")
        current_dir = os.getcwd()
        os.chdir(path)

        try:
            # Check if backend config exists
            if not TFBackend.backend_exists(components):
                Logger.error(f"Backend configuration for {components} does not exist. Please generate it first.")
                raise Exception

            # Initialize the backend (if not already done for this project)
            Logger.info("Running terraform init")
            rc = run(f"{FLAVOR} init -backend-config=\"{TFBackend.get_backend_path(components)}\"", shell=True)
            if rc != 0:
                raise Exception
            
            # Create workspaces
            Logger.info("Creating workspaces if they do not exist")
            for env in ENVIRONMENTS:
                subprocess.run([FLAVOR, "workspace", "new", env], check=False)
                
            # Select the workspace based on the environment
            Logger.info(f"Selecting workspace: {self.environment}")
            rc = run(f"{FLAVOR} workspace select {self.environment}", shell=True)
            if rc != 0:
                raise Exception
        except subprocess.CalledProcessError as e:
            Logger.error("Terraform initialization failed")
            raise e
        finally:
            os.chdir(current_dir) # Always change back to the original directory
        Logger.success("Terraform initialized successfully")
    
    def get_filename_tfvars(self):
        return TFVARS.get_filename_tfvars(self.environment)

    def get_path_tfvars(self):
        return f"{PATH}/{self.get_filename_tfvars()}"
    
    '''
    Validate automated.tfvars is set, and values are set
    '''
    def check_values(self):
        # Check if automated.tfvars exists
        tfvars_path = self.get_path_tfvars()
        if not os.path.exists(tfvars_path):
            Logger.error(f"{self.get_filename_tfvars()} not found. Please create the file and try again")
            exit(1)

        # Load tfvars file
        tfvars_data = TFVARS.safe_load_tfvars(tfvars_path)
        
        # Check if fields include "<" or ">"
        def check_placeholders(value):
            if isinstance(value, str) and "<" in value and ">" in value:
                return True
            elif isinstance(value, dict):
                for v in value.values():
                    if check_placeholders(v):
                        return True
            elif isinstance(value, list):
                for item in value:
                    if check_placeholders(item):
                        return True
            return False
        for key, value in tfvars_data.items():
            if check_placeholders(value):
                Logger.error(f"{self.get_filename_tfvars()} does not seem to be filled out (see field '{key}'). Please fill out all fields and try again")
                exit(1)

        Logger.info(f"{self.get_filename_tfvars()} is filled out correctly")

    def cluster_deploy(self):
        Logger.info("Deploying the cluster")

        # Configure tfvars file
        tfvars = TFVARS(self.get_path_tfvars(), f"{PATH}/cluster/data.auto.tfvars")
        tfvars.create(CLUSTER_TFVARS)
        # tfvars.add("environment", self.environment)
        Logger.space()
        
        # Deploy the cluster
        try:
            self.init_terraform(f"{PATH}/cluster", "cluster")
            cmd = f"cd \"{PATH}/cluster\" && {FLAVOR} apply {AUTO_APPLY and '-auto-approve' or ''}"
            rc = run(cmd, shell=True)
            if rc != 0:
                raise Exception
        except Exception:
            Logger.error("Cluster terraform failed")
        Logger.success("Cluster terraform applied successfully")
        # Export kubeconfig
        self.export_kubeconfig()
        Logger.success("Cluster deployed successfully")
        
    def export_kubeconfig(self):
        Logger.info("Exporting kubeconfig")
        
        # Export kubeconfig
        try:
            rc = run(f"cd \"{PATH}/cluster\" && {FLAVOR} output --raw kubeconfig > \"{PATH}\"/kube-config/kube-config.{self.environment}.yml")
            if rc != 0:
                raise Exception
            rc = run(f"cat \"{PATH}\"/kube-config/kube-config.{self.environment}.yml | base64 -w0 > \"{PATH}\"/kube-config/kube-config.{self.environment}.b64")
            if rc != 0:
                raise Exception
        except:
            Logger.error("Failed to export kubeconfig")
        Logger.success("Kubeconfig exported")
    
    def get_kubeconfig_b64(self):
        try:
            with open(f"{PATH}/kube-config/kube-config.{self.environment}.b64", "r") as file:
                return file.read()
        except FileNotFoundError:  
            Logger.error("Kubeconfig file not found. Please deploy the cluster first.")
            exit(1)  
        except OSError as e:  
            Logger.error(f"Failed to read kubeconfig file: {e}")
            exit(1) 
    
    def ops_deploy(self):
        Logger.info("Deploying the ops on the cluster")

        # Configure tfvars file
        tfvars = TFVARS(self.get_path_tfvars(), f"{PATH}/ops/data.auto.tfvars")
        tfvars.create(OPS_TFVARS)
        tfvars.add_dict({
            "kubeconfig": self.get_kubeconfig_b64(),
            "environment": self.environment
        })
        Logger.space()
        
        # Deploy the cluster
        try:
            self.init_terraform(f"{PATH}/ops", "ops")
            rc = run(f"cd \"{PATH}/ops\" && {FLAVOR} apply {AUTO_APPLY and '-auto-approve' or ''}", shell=True)
            if rc != 0:
                raise Exception
        except:
            Logger.error("Ops apply failed")
        Logger.success("Ops deployed successfully")
    
    def platform_deploy(self):
        Logger.info("Deploying the platform on the cluster")

        # Configure tfvars file
        tfvars = TFVARS(self.get_path_tfvars(), f"{PATH}/platform/data.auto.tfvars")
        tfvars.create(PLATFORM_TFVARS)
        tfvars.add_dict({
            "kubeconfig": self.get_kubeconfig_b64(),
            "environment": self.environment
        })
        Logger.space()
        
        # Deploy the cluster
        try:
            self.init_terraform(f"{PATH}/platform", "platform")
            rc = run(f"cd \"{PATH}/platform\" && {FLAVOR} apply {AUTO_APPLY and '-auto-approve' or ''}", shell=True)
            if rc != 0:
                raise Exception
        except:
            Logger.error("Platform apply failed")
        Logger.success("Platform deployed successfully")

    def challenges_deploy(self):
        Logger.info("Deploying the challenges on the cluster")

        # Configure tfvars file
        tfvars = TFVARS(self.get_path_tfvars(), f"{PATH}/challenges/data.auto.tfvars")
        tfvars.create(CHALLENGES_TFVARS)
        tfvars.add_dict({
            "kubeconfig": self.get_kubeconfig_b64(),
            "environment": self.environment
        })
        Logger.space()
        
        # Deploy the cluster
        try:
            self.init_terraform(f"{PATH}/challenges", "challenges")
            rc = run(f"cd \"{PATH}/challenges\" && {FLAVOR} apply {AUTO_APPLY and '-auto-approve' or ''}", shell=True)
            if rc != 0:
                raise Exception
        except:
            Logger.error("Challenges apply failed")
        Logger.success("Challenges deployed successfully")

'''
Destroy the platform
'''
class Destroy(Command):
    name = "destroy"
    help = "Destroy the platform"
    description = "Destroy the platform"
    times = []
    environment = "test"  # Default environment

    def register_subcommand(self):
        # Only run listed parts of the destruction
        self.subparser.add_argument("--cluster", action="store_true", help="Destroy the cluster")
        self.subparser.add_argument("--ops", action="store_true", help="Destroy the ops")
        self.subparser.add_argument("--platform", action="store_true", help="Destroy the platform")
        self.subparser.add_argument("--challenges", action="store_true", help="Destroy the challenges")
        self.subparser.add_argument("--all", action="store_true", help="Destroy all parts of the platform")   
        self.subparser.add_argument("--test", action="store_true", help="Destroy TEST cluster (default)")
        self.subparser.add_argument("--dev", action="store_true", help="Destroy DEV cluster")
        self.subparser.add_argument("--prod", action="store_true", help="Destroy PROD cluster")     
        return

    def run(self, args):
        global AUTO_APPLY
        
        if not args.cluster and not args.ops and not args.platform and not args.challenges and not args.all:
            Logger.error("Please specify which part of the platform to destroy")
            exit(1)
            
        if args.all and (args.cluster or args.ops or args.platform or args.challenges):
            Logger.error("Please specify only --all or individual parts of the platform")
            exit(1)
            
        if [args.test, args.dev, args.prod].count(True) > 1:
            Logger.error("Please specify only one environment: --test, --dev or --prod")
            exit(1)
                        
        if args.prod:
            AUTO_APPLY = False  # Disable auto-apply for production environment
            
        destroy_all = args.all
        destroy_cluster = args.cluster or destroy_all
        destroy_ops = args.ops or destroy_all
        destroy_platform = args.platform or destroy_all
        destroy_challenges = args.challenges or destroy_all
        
        self.environment = "test"
        if args.dev:
            self.environment = "dev"
        elif args.prod:
            self.environment = "prod"
        
        self.times.append(("start", time.time()))
        Logger.info("Destroying " + (self.environment.upper() if self.environment != "test" else "TEST") + " environment")
        Logger.space()
        
        if destroy_challenges:
            start_time = time.time()
            self.challenges_destroy()
            self.times.append(("challenges", start_time, time.time(), time.time() - start_time))
            Logger.space()
            Logger.info(f"Time taken: {str(round(self.times[-1][3], 2))} seconds")
            Logger.space()
            
        if destroy_platform:
            start_time = time.time()
            self.platform_destroy()
            self.times.append(("platform", start_time, time.time(), time.time() - start_time))
            Logger.space()
            Logger.info(f"Time taken: {str(round(self.times[-1][3], 2))} seconds")
            Logger.space()
        
        if destroy_ops:
            start_time = time.time()
            self.ops_destroy()
            self.times.append(("ops", start_time, time.time(), time.time() - start_time))
            Logger.space()
            Logger.info(f"Time taken: {str(round(self.times[-1][3], 2))} seconds")
            Logger.space()
            
        if destroy_cluster:
            start_time = time.time()
            self.cluster_destroy()
            self.times.append(("cluster", start_time, time.time(), time.time() - start_time))
            Logger.space()
            Logger.info(f"Time taken: {str(round(self.times[-1][3], 2))} seconds")
            Logger.space()

        Logger.success("Destroyed action")
        
        self.times.append(("end", time.time()))
        
        Logger.info(f"Time taken: {str(round(Utils.extract_tuple_from_list(self.times, 'end')[1] - Utils.extract_tuple_from_list(self.times, 'start')[1], 2))} seconds")
        
        if destroy_cluster:
            Logger.info(f"Cluster time: {str(round(Utils.extract_tuple_from_list(self.times, 'cluster')[3], 2))} seconds")
        if destroy_ops:
            Logger.info(f"Ops time: {str(round(Utils.extract_tuple_from_list(self.times, 'ops')[3], 2))} seconds")
        if destroy_platform:
            Logger.info(f"Platform time: {str(round(Utils.extract_tuple_from_list(self.times, 'platform')[3], 2))} seconds")
        if destroy_challenges:
            Logger.info(f"Challenges time: {str(round(Utils.extract_tuple_from_list(self.times, 'challenges')[3], 2))} seconds")
    
    '''
    Initialize Terraform to a given environment (workspace)
    '''
    def init_terraform(self, path, components: str = ""):
        Logger.info("Initializing Terraform")
        current_dir = os.getcwd()
        os.chdir(path)

        try:
            # Check if backend config exists
            if not TFBackend.backend_exists(components):
                Logger.error(f"Backend configuration for {components} does not exist. Please generate it first.")
                raise Exception

            # Initialize the backend (if not already done for this project)
            Logger.info("Running terraform init")
            rc = run(f"{FLAVOR} init -backend-config=\"{TFBackend.get_backend_path(components)}\"", shell=True)
            if rc != 0:
                raise Exception
            
            # Create workspaces
            Logger.info("Creating workspaces if they do not exist")
            for env in ENVIRONMENTS:
                subprocess.run([FLAVOR, "workspace", "new", env], check=False)
                
            # Select the workspace based on the environment
            Logger.info(f"Selecting workspace: {self.environment}")
            rc = run(f"{FLAVOR} workspace select {self.environment}", shell=True)
            if rc != 0:
                raise Exception
        except subprocess.CalledProcessError as e:
            Logger.error("Terraform initialization failed")
            raise e
        finally:
            os.chdir(current_dir) # Always change back to the original directory
        Logger.success("Terraform initialized successfully")
    
    def get_filename_tfvars(self):
        return TFVARS.get_filename_tfvars(self.environment)

    def get_path_tfvars(self):
        return f"{PATH}/{self.get_filename_tfvars()}"
    
    def get_kubeconfig_b64(self):
        try:
            with open(f"{PATH}/kube-config/kube-config.{self.environment}.b64", "r") as file:
                return file.read()
        except FileNotFoundError:  
            Logger.error("Kubeconfig file not found. Please deploy the cluster first.")
            exit(1)  
        except OSError as e:  
            Logger.error(f"Failed to read kubeconfig file: {e}")
            exit(1) 
    
    def cluster_destroy(self):
        Logger.info("Destroying the cluster")
        
        
        # Configure tfvars file
        tfvars = TFVARS(self.get_path_tfvars(), f"{PATH}/cluster/data.auto.tfvars")
        tfvars.create(CLUSTER_TFVARS)
        # tfvars.add("environment", self.environment)
        Logger.space()
        
        # Destroy the cluster
        try:
            self.init_terraform(f"{PATH}/cluster", "cluster")
            rc = run(f"cd \"{PATH}/cluster\" && {FLAVOR} workspace select {self.environment} && {FLAVOR} destroy {AUTO_APPLY and '-auto-approve' or ''}", shell=True)
            if rc != 0:
                raise Exception
        except:
            Logger.error("Cluster terraform destroy failed")
        
        # Remove the tfvars file
        TFVARS(self.get_path_tfvars(), f"{PATH}/cluster/data.auto.tfvars").destroy()
        
        Logger.success("Cluster terraform destroy applied successfully")
        
        # remove kubeconfig
        self.remove_kubeconfig()
    
    def remove_kubeconfig(self):
        Logger.info("Removing kubeconfig")
        
        # Remove kubeconfig
        try:
            rc = run(f"rm \"{PATH}\"/kube-config/kube-config.{self.environment}.yml", shell=True)
            if rc != 0:
                raise Exception
            rc = run(f"rm \"{PATH}\"/kube-config/kube-config.{self.environment}.b64", shell=True)
            if rc != 0:
                raise Exception
        except:
            Logger.error("Failed to remove kubeconfig")
        Logger.success("Kubeconfig removed")
    
    def ops_destroy(self):
        Logger.info("Destroying the ops on the cluster")
        
        # Configure tfvars file
        tfvars = TFVARS(self.get_path_tfvars(), f"{PATH}/ops/data.auto.tfvars")
        tfvars.create(OPS_TFVARS)
        tfvars.add_dict({
            "kubeconfig": self.get_kubeconfig_b64(),
            "environment": self.environment
        })
        Logger.space()
        
        # Destroy the ops
        try:
            self.init_terraform(f"{PATH}/ops", "ops")
            rc = run(f"cd \"{PATH}/ops\" && {FLAVOR} workspace select {self.environment} && {FLAVOR} destroy {AUTO_APPLY and '-auto-approve' or ''}", shell=True)
            if rc != 0:
                raise Exception
        except:
            Logger.error("Ops destroy failed")
        
        # Remove the tfvars file
        TFVARS(self.get_path_tfvars(), f"{PATH}/ops/data.auto.tfvars").destroy()
        
        Logger.success("Ops destroyed successfully")
    
    def platform_destroy(self):
        Logger.info("Destroying the platform on the cluster")

        # Configure tfvars file
        tfvars = TFVARS(self.get_path_tfvars(), f"{PATH}/platform/data.auto.tfvars")
        tfvars.create(PLATFORM_TFVARS)
        tfvars.add_dict({
            "kubeconfig": self.get_kubeconfig_b64(),
            "environment": self.environment
        })
        Logger.space()
        
        # Destroy the platform
        try:
            self.init_terraform(f"{PATH}/platform", "platform")
            rc = run(f"cd \"{PATH}/platform\" && {FLAVOR} workspace select {self.environment} && {FLAVOR} destroy {AUTO_APPLY and '-auto-approve' or ''}", shell=True)
            if rc != 0:
                raise Exception
        except:
            Logger.error("Platform destroy failed")
        
        # Remove the tfvars file
        TFVARS(self.get_path_tfvars(), f"{PATH}/platform/data.auto.tfvars").destroy()
        
        Logger.success("Platform destroyed successfully")
        
    def challenges_destroy(self):
        Logger.info("Destroying the challenges on the cluster")

        # Configure tfvars file
        tfvars = TFVARS(self.get_path_tfvars(), f"{PATH}/challenges/data.auto.tfvars")
        tfvars.create(CHALLENGES_TFVARS)
        tfvars.add_dict({
            "kubeconfig": self.get_kubeconfig_b64(),
            "environment": self.environment
        })
        Logger.space()
        
        # Destroy the challenges
        try:
            self.init_terraform(f"{PATH}/challenges", "challenges")
            rc = run(f"cd \"{PATH}/challenges\" && {FLAVOR} workspace select {self.environment} && {FLAVOR} destroy {AUTO_APPLY and '-auto-approve' or ''}", shell=True)
            if rc != 0:
                raise Exception
        except:
            Logger.error("Challenges destroy failed")
        
        # Remove the tfvars file
        TFVARS(self.get_path_tfvars(), f"{PATH}/challenges/data.auto.tfvars").destroy()
        
        Logger.success("Challenges destroyed successfully")

'''
TFVars handler class
'''
class TFVARS:
    root: str
    destination: str
    
    def __init__(self, root, destination):
        self.root = root
        self.destination = destination

    @staticmethod
    def get_filename_tfvars(environment="test"):
        '''
        Get the filename for the tfvars file based on the environment
        
        :param environment: The environment name (test, dev, prod)
        :return: The filename for the tfvars file
        '''
        
        prefix = ""
        if environment != "test":
            prefix = f"{environment}."

        return f"automated.{prefix}tfvars"
    
    @staticmethod
    def load_tfvars(file_path: str):
        '''
        Load a tfvars file and return its contents as a dictionary
        
        :param file_path: The path to the tfvars file
        :return: A dictionary containing the tfvars key-value pairs
        '''
        
        with open(file_path, "r") as tfvars_file:
            tfvars = hcl2.api.load(tfvars_file)
        return tfvars

    @staticmethod
    def safe_load_tfvars(file_path: str):
        '''
        Safely load a tfvars file and handle errors by exiting the program
        
        :param file_path: The path to the tfvars file
        :return: A dictionary containing the tfvars key-value pairs
        '''
        
        try:
            return TFVARS.load_tfvars(file_path)
        except FileNotFoundError:  
            Logger.error("tfvars file not found. Please create the file and try again.")
            exit(1)
        except Exception as e:
            Logger.error(f"Error loading tfvars file: {e}")
            exit(1)
            
    @staticmethod
    def safe_write_tfvars(file_path: str, data: dict):
        '''
        Safely write a dictionary to a tfvars file and handle errors by exiting the program
        
        :param file_path: The path to the tfvars file
        :param data: A dictionary containing the tfvars key-value pairs
        :return: None
        '''
        
        try:
            tree = hcl2.api.reverse_transform(data)
            formatted_data = hcl2.api.writes(tree)
            
            with open(file_path, "w") as tfvars_file:
                tfvars_file.write(formatted_data)
        except Exception as e:
            Logger.error(f"Error writing tfvars file: {e}")
            exit(1)
    
    def create(self, fields=[]):
        # Check if destination exists
        exists = os.path.exists(self.destination)

        # Create the file or empty it
        with open(self.destination, "w") as file:
            if exists:
                Logger.info(f"Overwriting {self.destination}")
            else:
                Logger.info(f"Creating {self.destination}")

            file.write("")

        # Parse the root file into key-value pairs
        key_value_pairs = TFVARS.safe_load_tfvars(self.root)

        # Filter and write only the specified fields to the destination file
        filtered_values = {}
        for field in fields:
            if field in key_value_pairs:
                filtered_values[field] = key_value_pairs[field]
            else:
                Logger.warning(f"Field '{field}' not found in {self.root}")
        TFVARS.safe_write_tfvars(self.destination, filtered_values)
    
    def add(self, key, value):
        '''
        Add a key-value pair to the tfvars file
        
        :param key: The key to add
        :param value: The value to add
        :return: None
        '''
        
        # Check if destination exists
        exists = os.path.exists(self.destination)
        if not exists:
            Logger.error(f"{self.destination} does not exist")
            exit(1)
        
        data = TFVARS.safe_load_tfvars(self.destination)
        data[key] = value
        TFVARS.safe_write_tfvars(self.destination, data)
    
    def add_dict(self, dict_data):
        '''
        Add multiple key-value pairs from a dictionary to the tfvars file
        
        :param dict_data: A dictionary containing the key-value pairs to add
        :return: None
        '''
        
        # Check if destination exists
        exists = os.path.exists(self.destination)
        if not exists:
            Logger.error(f"{self.destination} does not exist")
            exit(1)
        
        data = TFVARS.safe_load_tfvars(self.destination)
        for key, value in dict_data.items():
            data[key] = value
        TFVARS.safe_write_tfvars(self.destination, data)
    
    def destroy(self):
        # Check if destination exists
        exists = os.path.exists(self.destination)
            
        # Remove the file
        if exists:
            Logger.info(f"Removing {self.destination}")
            os.remove(self.destination)
        else:
            Logger.info(f"{self.destination} does not exist")

    @staticmethod
    def insert_keys(environment="test"):
        
        # Read the keys
        public_key = ""
        private_key = ""
        try:  
            with open(f"{PATH}/data/keys/k8s.pub.b64", "r") as file:  
                public_key = file.read()
            with open(f"{PATH}/data/keys/k8s.b64", "r") as file:  
                private_key = file.read()
        except FileNotFoundError:  
            Logger.error("SSH keys not found. Please run 'generate-keys' first.")  
            exit(1)  
        except OSError as e:  
            Logger.error(f"Failed to read SSH key files: {e}")  
            exit(1)  
        
        data = TFVARS.safe_load_tfvars(f"{PATH}/{TFVARS.get_filename_tfvars(environment)}")
        data["ssh_key_public_base64"] = public_key
        data["ssh_key_private_base64"] = private_key
        TFVARS.safe_write_tfvars(f"{PATH}/{TFVARS.get_filename_tfvars(environment)}", data)

'''
CLI tool
'''
class CLI:
    def run(self):
        self.platform_check()
        
        args = Args()
        if args.parser is None:
            Logger.error("Failed to initialize argument parser")
            exit(1)
        
        subparser = args.parser.add_subparsers(dest="command", help="Subcommand to run", title="subcommands")

        # Commands
        commands = [
            InitializeTFVars(subparser),
            GenerateImages(subparser),
            GenerateKeys(subparser), 
            InsertKeys(subparser),
            Deploy(subparser),
            Destroy(subparser),
            backend_generate.Generator(subparser)
        ]
        for command in commands:
            command.register_subcommand()
        
        # Get arguments
        namespace = args.parser.parse_args()
        
        # Fallback to help if no subcommand is provided
        if not hasattr(namespace, "func"):
            args.print_help()
            exit(1)
        
        # Run the subcommand
        try:
            namespace.func(namespace)
        except Exception as e:
            Logger.error(f"Failed to run subcommand: {e}")

    def platform_check(self):
        # Check if system is linux
        if sys.platform != "linux":
            Logger.error("This script is only supported on Linux")
            exit(1)
        
        # Check if user has bash
        if not os.path.exists("/bin/bash"):
            Logger.error("This script requires bash")
            exit(1)

if __name__ == "__main__":    
    CLI().run()
