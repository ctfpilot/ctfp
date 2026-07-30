#!/usr/bin/env python3

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
import shutil

# Terraform parser - https://github.com/amplify-education/python-hcl2
import hcl2

import backend.generate as backend_generate

AUTO_APPLY = False
ENVIRONMENTS = ["test", "dev", "prod"]
FLAVOR = "tofu" # Can be "terraform" or "tofu". Only tested with "tofu"
COMPONENTS = ["cluster", "ops", "platform", "challenges"]

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
    "challs_type",
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
    "deployment_type",
    "email", 
    "discord_webhook_url",
    
    # Cloudflare variables
    "cloudflare_api_token", 
    "cloudflare_dns_management", 
    "cloudflare_dns_platform",
    "cloudflare_dns_ctf", 
    "cluster_dns_management", 
    
    # Traefik configuration
    "traefik_redis_password",
    
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
    
    # Replicas
    "argocd_redis_ha",
    "argocd_controller_replicas",
    "argocd_server_replicas",
    "argocd_repo_server_replicas",
    "argocd_application_set_replicas",
    "errors_replicas",
    "default_web_replicas",
]
PLATFORM_TFVARS = [
    # Generic information
    "deployment_type",
    "cluster_dns_management", 
    "cluster_dns_platform",
    
    # GitHub variables    
    "ghcr_username",
    "ghcr_token",
    "git_token",
    
    # Traefik configuration
    "traefik_redis_password",

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
    # Redis configuration
    "ctfd_redis_password",
    
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
    "deployment_type",
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


# Validate PATH: reject if it contains special characters that may break shell commands
for char in [' ', '"', "'", '&', ';', '$', '>', '<', '|', '`', '!', '*', '?', '(', ')', '[', ']', '{', '}', '~']:
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
    version = "v2.21.0"
    
    def register_subcommand(self):
        self.subparser.add_argument("--version", type=str, default=self.version, help="Version of the create.sh script to use (default: v2.21.0)")
        return
    
    def run(self, args):
        Logger.info("Generating server images")
        try:
            rc = run(f"cd \"{PATH}/cluster\" && tmp_script=$(mktemp) && curl -sSL -o \"${{tmp_script}}\" https://raw.githubusercontent.com/kube-hetzner/terraform-hcloud-kube-hetzner/refs/tags/{self.version}/scripts/create.sh && chmod +x \"${{tmp_script}}\" && \"${{tmp_script}}\" && rm \"${{tmp_script}}\"")
            if rc != 0:
                raise Exception
        except Exception:
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
            shutil.copyfile(template, destination)
        except Exception:
            Logger.error(f"Failed to initialize {self.get_filename_tfvars()}")
        Logger.success(f"{self.get_filename_tfvars()} initialized successfully")
    
    def get_filename_tfvars(self):
        return TFVARS.get_filename_tfvars(self.environment)

'''
Generate SSH keys
'''
class GenerateKeys(Command):
    name = "generate-keys"
    help = "Generate SSH keys"
    description = "Generate SSH keys"
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
            
        Logger.info("Generating SSH keys")
        try:
            rc = run([f"\"{PATH}\"/keys/create.sh \"{self.environment}\""])
            if rc != 0:
                raise Exception
        except Exception:
            Logger.error("Failed to generate keys")
        
        Logger.success("Keys generated successfully in keys/ using ed25519")
        Logger.info(f"Public key: keys/k8s-{self.environment}.pub")
        Logger.info(f"Private key: keys/k8s-{self.environment}")
        
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
    environment = "test" # Default environment
    components = COMPONENTS + ["all"]

    def register_subcommand(self):
        self.subparser.add_argument("component", help="Component to deploy (cluster, ops, platform, challenges, all)", choices=self.components)
        self.subparser.add_argument("--test", action="store_true", help="Deploy TEST cluster (default)")
        self.subparser.add_argument("--dev", action="store_true", help="Deploy DEV cluster")
        self.subparser.add_argument("--prod", action="store_true", help="Deploy PROD cluster")
        self.subparser.add_argument("--auto-apply", action="store_true", help="Automatically apply Terraform changes without prompting")
        return

    def run(self, args):
        global AUTO_APPLY

        # Check component is valid
        component = args.component.lower()
        if component not in COMPONENTS and component != "all":
            Logger.error(f"Invalid component. Please specify one of: {', '.join(self.components)}")
            exit(1)
        
        if [args.test, args.dev, args.prod].count(True) > 1:
            Logger.error("Please specify only one environment: --test, --dev or --prod")
            exit(1)
        
        if args.auto_apply:
            AUTO_APPLY = True
        
        deploy_all = component == "all"

        self.environment = "test"
        if args.dev:
            self.environment = "dev"
        elif args.prod:
            self.environment = "prod"

        times = {}
        times["start"] = time.time()
        Logger.info("Deploying " + (self.environment.upper() if self.environment != "test" else "TEST") + " environment")
        Logger.space()
        
        terraform = Terraform(self.environment)
        Logger.space()

        if deploy_all or component == "cluster":
            component_start = time.time()
            terraform.cluster_deploy()
            times["cluster"] = time.time() - component_start
            Logger.space()
            Logger.info(f"Time taken: {round(times['cluster'], 2)} seconds")
            Logger.space()
        
        if deploy_all or component == "ops":
            component_start = time.time()
            terraform.ops_deploy()
            times["ops"] = time.time() - component_start
            Logger.space()
            Logger.info(f"Time taken: {round(times['ops'], 2)} seconds")
            Logger.space()
        
        if deploy_all or component == "platform":
            component_start = time.time()
            terraform.platform_deploy()
            times["platform"] = time.time() - component_start
            Logger.space()
            Logger.info(f"Time taken: {round(times['platform'], 2)} seconds")
            Logger.space()
        
        if deploy_all or component == "challenges":
            component_start = time.time()
            terraform.challenges_deploy()
            times["challenges"] = time.time() - component_start
            Logger.space()
            Logger.info(f"Time taken: {round(times['challenges'], 2)} seconds")
            Logger.space()
        
        Logger.success("Platform deployed")
        total_time = time.time() - times["start"]

        Logger.info(f"Time taken: {round(total_time, 2)} seconds")
        
        if deploy_all or component == "cluster":
            Logger.info(f"Cluster time: {round(times['cluster'], 2)} seconds")
        if deploy_all or component == "ops":
            Logger.info(f"Ops time: {round(times['ops'], 2)} seconds")
        if deploy_all or component == "platform":
            Logger.info(f"Platform time: {round(times['platform'], 2)} seconds")
        if deploy_all or component == "challenges":
            Logger.info(f"Challenges time: {round(times['challenges'], 2)} seconds")

'''
Destroy the platform
'''
class Destroy(Command):
    name = "destroy"
    help = "Destroy the platform"
    description = "Destroy the platform"
    times = []
    environment = "test"  # Default environment
    components = COMPONENTS + ["all"]

    def register_subcommand(self):
        # Only run listed parts of the destruction
        self.subparser.add_argument("component", help="Component to destroy (cluster, ops, platform, challenges, all)", choices=self.components)  
        self.subparser.add_argument("--test", action="store_true", help="Destroy TEST cluster (default)")
        self.subparser.add_argument("--dev", action="store_true", help="Destroy DEV cluster")
        self.subparser.add_argument("--prod", action="store_true", help="Destroy PROD cluster")     
        self.subparser.add_argument("--auto-apply", action="store_true", help="Automatically apply Terraform changes without prompting")
        return

    def run(self, args):
        global AUTO_APPLY

        # Check component is valid
        component = args.component.lower()
        if component not in COMPONENTS and component != "all":
            Logger.error(f"Invalid component. Please specify one of: {', '.join(self.components)}")
            exit(1)

        if [args.test, args.dev, args.prod].count(True) > 1:
            Logger.error("Please specify only one environment: --test, --dev or --prod")
            exit(1)

        if args.auto_apply:
            AUTO_APPLY = True
            
        destroy_all = component == "all"
        
        self.environment = "test"
        if args.dev:
            self.environment = "dev"
        elif args.prod:
            self.environment = "prod"
        
        times = {}
        times["start"] = time.time()
        Logger.info("Destroying " + (self.environment.upper() if self.environment != "test" else "TEST") + " environment")
        Logger.space()
        
        terraform = Terraform(self.environment)
        
        if destroy_all or component == "challenges":
            component_start = time.time()
            terraform.challenges_destroy()
            times["challenges"] = time.time() - component_start
            Logger.space()
            Logger.info(f"Time taken: {round(times['challenges'], 2)} seconds")
            Logger.space()
            
        if destroy_all or component == "platform":
            component_start = time.time()
            terraform.platform_destroy()
            times["platform"] = time.time() - component_start
            Logger.space()
            Logger.info(f"Time taken: {round(times['platform'], 2)} seconds")
            Logger.space()
        
        if destroy_all or component == "ops":
            component_start = time.time()
            terraform.ops_destroy()
            times["ops"] = time.time() - component_start
            Logger.space()
            Logger.info(f"Time taken: {round(times['ops'], 2)} seconds")
            Logger.space()
            
        if destroy_all or component == "cluster":
            component_start = time.time()
            terraform.cluster_destroy()
            times["cluster"] = time.time() - component_start
            Logger.space()
            Logger.info(f"Time taken: {round(times['cluster'], 2)} seconds")
            Logger.space()

        Logger.success("Destroyed action")
        total_time = time.time() - times["start"]
        
        Logger.info(f"Time taken: {round(total_time, 2)} seconds")
        
        if destroy_all or component == "cluster":
            Logger.info(f"Cluster time: {round(times['cluster'], 2)} seconds")
        if destroy_all or component == "ops":
            Logger.info(f"Ops time: {round(times['ops'], 2)} seconds")
        if destroy_all or component == "platform":
            Logger.info(f"Platform time: {round(times['platform'], 2)} seconds")
        if destroy_all or component == "challenges":
            Logger.info(f"Challenges time: {round(times['challenges'], 2)} seconds")
    

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

        return f"automated.{environment}.tfvars"
    
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
            with open(f"{PATH}/keys/k8s-{environment}.pub.b64", "r") as file:  
                public_key = file.read()
            with open(f"{PATH}/keys/k8s-{environment}.b64", "r") as file:  
                private_key = file.read()
        except FileNotFoundError:  
            Logger.error("SSH keys not found. Please run 'generate-keys' first.")  
            exit(1)  
        except OSError as e:  
            Logger.error(f"Failed to read SSH key files: {e}")  
            exit(1)
        
        # Insert the keys into automated.tfvars (in place)
        with open(f"{PATH}/{TFVARS.get_filename_tfvars(environment)}", "r") as file:
            lines = file.readlines()
        with open(f"{PATH}/{TFVARS.get_filename_tfvars(environment)}", "w") as file:
            for line in lines:
                if "ssh_key_public_base64" in line:
                    file.write(f'ssh_key_public_base64 = "{public_key}"\n')
                elif "ssh_key_private_base64" in line:
                    file.write(f'ssh_key_private_base64 = "{private_key}"\n')
                else:
                    file.write(line)

'''
Terraform handler
'''
class Terraform:
    environment: str
    
    @staticmethod
    def is_installed():
        '''
        Check if Terraform is installed
        
        :return: True if installed, False otherwise
        '''
        try:
            rc = run(f"{FLAVOR} version")
            return rc == 0
        except Exception:
            return False

    def __init__(self, environment="test"):
        self.environment = environment

    '''
    Initialize Terraform to a given environment (workspace)
    '''
    def init_terraform(self, path, components: str = ""):
        Logger.info("Initializing Terraform")
        current_dir = os.getcwd()
        os.chdir(path)

        try:
            # Check if tfvars file exists and is valid
            self.check_values()
            
            # Load backend connection credentials
            self.load_backend_credentials()
        
            # Check if backend config exists
            if not TFBackend.backend_exists(components):
                Logger.error(f"Backend configuration for {components} does not exist. Please generate it first.")
                raise Exception

            # Initialize the backend (if not already done for this project)
            Logger.info("Running terraform init")
            rc = run(f"{FLAVOR} init -backend-config=\"{TFBackend.get_backend_path(components)}\"")
            if rc != 0:
                # Try to init with reconfigure
                response = input(f"The init of the backend for {components} failed. Do you want to try to reconfigure the backend? (y/N): ")
                if response.lower() != "y":
                    Logger.info("Exiting")
                    exit(0)
                
                Logger.warning("Reconfiguring backend")
                rc = run(f"{FLAVOR} init -reconfigure -backend-config=\"{TFBackend.get_backend_path(components)}\"")
                if rc != 0:
                    raise Exception
            
            # Create workspaces
            Logger.info("Creating workspaces if they do not exist")
            for env in ENVIRONMENTS:
                subprocess.run([FLAVOR, "workspace", "new", env], check=False)
                
            # Select the workspace based on the environment
            Logger.info(f"Selecting workspace: {self.environment}")
            rc = run(f"{FLAVOR} workspace select {self.environment}")
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
    
    def execute(self, component, generate_plan=True, action="apply"):
        '''
        Execute Terraform action (apply or destroy)
        
        :param component: The component to execute
        :param generate_plan: Whether to generate a plan before executing
        :param action: The action to execute (apply or destroy)
        '''
        if action not in ["apply", "destroy"]:
            Logger.error("Invalid action. Must be 'apply' or 'destroy'")
            exit(1)
        
        is_apply = action == "apply"
        
        # Initialize Terraform
        component_path = f"{PATH}/{component}"
        self.init_terraform(component_path, component)
        
        rc = 0
        if generate_plan:
            # Generate plan
            Logger.info("Generating Terraform plan")
            rc = run(f"cd \"{component_path}\" && {FLAVOR} workspace select {self.environment} && {FLAVOR} plan {'' if is_apply else '-destroy'} -out=\"{PATH}/terraform/{component}-{self.environment}.tfplan\"")
            if rc != 0:
                raise Exception(f"Terraform plan failed for {component} ({action}), with return code: {rc}")
            
            # Store the plan as human-readable output (Allowing user to review it)
            rc = run(f"cd \"{component_path}\" && {FLAVOR} show -no-color \"{PATH}/terraform/{component}-{self.environment}.tfplan\" > \"{PATH}/terraform/{component}-{self.environment}.plan.txt\"")
            if rc != 0:
                raise Exception(f"Terraform show plan failed for {component} ({action}), with return code: {rc}")
            
            Logger.success(f"Terraform plan generated successfully - It can be found at terraform/{component}-{self.environment}.plan.txt")
            
            # Ask if user wants to proceed
            if not AUTO_APPLY:
                response = input(f"Do you want to apply this plan on {component} ({action} {component} in {self.environment})? (y/N): ")
                if response.lower() != "y":
                    Logger.info(f"Exiting without applying the plan on {component} ({action})")
                    exit(0)
        
            # Run apply
            rc = run(f"cd \"{component_path}\" && {FLAVOR} workspace select {self.environment} && {FLAVOR} apply \"{PATH}/terraform/{component}-{self.environment}.tfplan\"")
            
            # Remove the plan files
            os.remove(f"{PATH}/terraform/{component}-{self.environment}.tfplan")

            # Move human readable plan to .old
            os.rename(f"{PATH}/terraform/{component}-{self.environment}.plan.txt", f"{PATH}/terraform/{component}-{self.environment}.plan.txt.old")
        else:
            # Run apply directly
            rc = run(f"cd \"{component_path}\" && {FLAVOR} {action} {'-auto-approve' if AUTO_APPLY else ''}")
        if rc != 0:
            raise Exception(f"Terraform {action} failed for {component}, with return code: {rc}")
    
    '''
    Run Terraform apply
    '''
    def apply(self, component, generate_plan=True):
        '''
        Run Terraform apply
        
        :param component: The component to apply
        :param generate_plan: Whether to generate a plan before applying
        '''
        self.execute(component, generate_plan, action="apply")
    
    '''
    Run Terraform destroy
    '''
    def destroy(self, component, generate_plan=True):
        '''
        Run Terraform destroy
        
        :param component: The component to destroy
        :param generate_plan: Whether to generate a plan before destroying
        '''
        self.execute(component, generate_plan, action="destroy")
    
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
            if isinstance(value, str) and (value.startswith("<") or value.startswith("https://github.com/<")) and value.endswith(">"):
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


    def load_backend_credentials(self):
        '''
        Load S3 backend credentials from automated.tfvars, to set Terraform S3 connection credentials
        '''
        
        # Load tfvars file
        tfvars_data = TFVARS.safe_load_tfvars(self.get_path_tfvars())
        
        # Set environment variables for S3 backend
        os.environ["AWS_ACCESS_KEY_ID"] = tfvars_data.get("terraform_backend_s3_access_key", "")
        os.environ["AWS_SECRET_ACCESS_KEY"] = tfvars_data.get("terraform_backend_s3_secret_key", "")
        
        if os.environ["AWS_ACCESS_KEY_ID"] == "" or os.environ["AWS_SECRET_ACCESS_KEY"] == "":
            Logger.error("S3 backend credentials not found in automated.tfvars. Please fill out terraform_backend_s3_access_key and terraform_backend_s3_secret_key as they are required to run the Terraform components.")
            exit(1)
        
        Logger.info(f"S3 backend credentials loaded")

    def cluster_deploy(self):
        Logger.info("Deploying the cluster")

        # Configure tfvars file
        tfvars = TFVARS(self.get_path_tfvars(), f"{PATH}/cluster/data.auto.tfvars")
        tfvars.create(CLUSTER_TFVARS)
        # tfvars.add("environment", self.environment)
        Logger.space()
        
        # Deploy the cluster
        try:
            self.apply("cluster")
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
        except Exception:
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
            self.apply("ops")
        except Exception:
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
            self.apply("platform")
        except Exception:
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
            self.apply("challenges")
        except Exception:
            Logger.error("Challenges apply failed")
        Logger.success("Challenges deployed successfully")

    def cluster_destroy(self):
        Logger.info("Destroying the cluster")
        
        # Configure tfvars file
        tfvars = TFVARS(self.get_path_tfvars(), f"{PATH}/cluster/data.auto.tfvars")
        tfvars.create(CLUSTER_TFVARS)
        # tfvars.add("environment", self.environment)
        Logger.space()
        
        # Destroy the cluster
        try:
            self.destroy("cluster")
        except Exception:
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
            rc = run(f"rm \"{PATH}\"/kube-config/kube-config.{self.environment}.yml")
            if rc != 0:
                raise Exception
            rc = run(f"rm \"{PATH}\"/kube-config/kube-config.{self.environment}.b64")
            if rc != 0:
                raise Exception
        except Exception:
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
            self.destroy("ops")
        except Exception:
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
            self.destroy("platform")
        except Exception:
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
            self.destroy("challenges")
        except Exception:
            Logger.error("Challenges destroy failed")
        
        # Remove the tfvars file
        TFVARS(self.get_path_tfvars(), f"{PATH}/challenges/data.auto.tfvars").destroy()
        
        Logger.success("Challenges destroyed successfully")

'''
CLI tool
'''
class CLI:
    def run(self):
        Logger.info("Starting CTF-Pilot CLI")
        
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
        
        Logger.info("Checking availability of required tools")
        self.platform_check()
        self.tool_check()
        Logger.success("Required Tools are available")
        
        # Run the subcommand
        try:
            namespace.func(namespace)
        except Exception as e:
            Logger.error(f"Failed to run subcommand: {e}")

    def platform_check(self):
        # Check if system is linux and if bash is available
        if sys.platform != "linux" or not os.path.exists("/bin/bash"):
            Logger.error("This script requires Linux and bash")
            exit(1)

    def tool_check(self):
        # Check if Terraform is installed
        if not Terraform.is_installed():
            Logger.error("Terraform is not installed. Please install Terraform and try again.")
            exit(1)
        
        # Check if curl is installed
        if run("which curl") != 0:
            Logger.error("curl is not installed. Please install curl and try again.")
            exit(1)
            
        # Check if base64 is installed
        if run("which base64") != 0:
            Logger.error("base64 is not installed. Please install base64 and try again.")
            exit(1)
        
        # Check if keygen is installed
        if run("which ssh-keygen") != 0:
            Logger.error("ssh-keygen is not installed. Please install ssh-keygen and try again.")
            exit(1)

if __name__ == "__main__":    
    CLI().run()
