import os
import sys
import argparse
import time
import subprocess

AUTO_APPLY = True
ENVIRONMENTS = ["test", "dev", "prod"]
FLAVOR = "tofu" # Can be "terraform" or "tofu"

CLUSTER_TFVARS = [
    # Server configuration
    "region_1",
    "region_2",
    "region_3",
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
    "scale_count",
    "scale_min",
    "load_balancer_type",
    
    # Cluster configuration
    "hcloud_token", 
    "ssh_key_private_base64", 
    "ssh_key_public_base64", 
    "cloudflare_api_token", 
    "cloudflare_dns_management", 
    "cloudflare_dns_ctf", 
    "cloudflare_dns_platform",
    "cluster_dns_management", 
    "cluster_dns_ctf",
    "cluster_dns_platform",
]
CONTENT_TFVARS = [
    "cloudflare_api_token", 
    "cloudflare_dns_management", 
    "cloudflare_dns_ctf", 
    "cloudflare_dns_platform",
    "cluster_dns_management", 
    "cluster_dns_ctf", 
    "email", 
    "argocd_github_secret",
    "argocd_admin_password", 
    "grafana_admin_password",
    "discord_webhook_url",
    "traefik_basic_auth",
    
    "filebeat_elasticsearch_host",
    "filebeat_elasticsearch_username",
    "filebeat_elasticsearch_password",
    
    "ghcr_username",
    "ghcr_token",
]
PLATFORM_TFVARS = [
    "cluster_dns_ctf",
    "cluster_dns_platform",
    "ghcr_username",
    "ghcr_token",
    "git_token",
    "kubectf_auth_secret",
    "db_root_password",
    "db_user",
    "db_password",
    "ctfd_manager_password",

    # S3 configuration
    "s3_bucket",
    "s3_region",
    "s3_endpoint",
    "s3_access_key",
    "s3_secret_key",
    
    # Elasticsearch configuration
    "filebeat_elasticsearch_host",
    "filebeat_elasticsearch_username",
    "filebeat_elasticsearch_password",

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
    "ctfd_discord_webhook_url",
    "ctf_s3_bucket",
    "ctf_s3_region",
    "ctf_s3_endpoint",
    "ctf_s3_access_key",
    "ctf_s3_secret_key",
    "ctf_s3_prefix",
]
CHALLENGES_TFVARS = [
    "cluster_dns_ctf",
    "ghcr_username",
    "ghcr_token",
    "git_token",
    "kubectf_auth_secret",
    "kubectf_container_secret",
    "chall_whitelist_ips",
]

# Load env from .env
if os.path.exists(".env"):
    with open(".env", "r") as f:
        for line in f:
            if line.strip() and not line.startswith("#"):
                key, value = line.strip().split("=", 1)
                os.environ[key.strip()] = value.strip()

def run(cmd, shell=True):
    """
    Run a subprocess in a new process group and forward KeyboardInterrupt (SIGINT) to it.
    Returns the process returncode.
    """
    import signal
    proc = subprocess.Popen(
        cmd,
        shell=shell,
        preexec_fn=os.setsid
    )
    try:
        proc.wait()
    except KeyboardInterrupt:
        os.killpg(proc.pid, signal.SIGINT)
        proc.wait()
    return proc.returncode

class Args:
    command = None
    parser = None
    
    def __init__(self):
        self.parser = argparse.ArgumentParser(description="Platform CLI")

    def print_help(self):
        if self.parser is None:
            Logger.error("Parser is not initialized")
            exit(1)
        
        self.parser.print_help()

class Utils:
    @staticmethod
    def get_path_to_script():
        path = os.path.dirname(os.path.realpath(__file__))
        
        # Check if the path contains spaces
        if " " in path:
            Logger.error("Path to script contains spaces. Please move the script to a path without spaces")
            exit(1)
            
        return path
    
    @staticmethod
    def extract_tuple_from_list(list, key):
        for item in list:
            if key in item:
                return item
        return None

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
        path = Utils.get_path_to_script()
        try:
            rc = run(f"cd {path}/cluster && tmp_script=$(mktemp) && curl -sSL -o \"${{tmp_script}}\" https://raw.githubusercontent.com/kube-hetzner/terraform-hcloud-kube-hetzner/master/scripts/create.sh && chmod +x \"${{tmp_script}}\" && \"${{tmp_script}}\" && rm \"${{tmp_script}}\"", shell=True)
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
        path = Utils.get_path_to_script()
        template = f"{path}/template.{self.get_filename_tfvars()}"
        destination = f"{path}/{self.get_filename_tfvars()}"

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
        path = Utils.get_path_to_script()
        try:
            rc = run([f"{path}/data/keys/create.sh"], shell=True)
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
        self.subparser.add_argument("--content", action="store_true", help="Deploy the content")
        self.subparser.add_argument("--platform", action="store_true", help="Deploy the platform")
        self.subparser.add_argument("--challenges", action="store_true", help="Deploy the challenges")
        self.subparser.add_argument("--all", action="store_true", help="Deploy all parts of the platform")
        self.subparser.add_argument("--test", action="store_true", help="Deploy TEST cluster (default)")
        self.subparser.add_argument("--dev", action="store_true", help="Deploy DEV cluster")
        self.subparser.add_argument("--prod", action="store_true", help="Deploy PROD cluster")
        return

    def run(self, args):
        if not args.cluster and not args.content and not args.platform and not args.challenges and not args.all:
            Logger.error("Please specify which part of the platform to deploy")
            exit(1)
            
        if args.all and (args.cluster or args.content or args.platform or args.challenges):
            Logger.error("Please specify only --all or individual parts of the platform")
            exit(1)

        if [args.test, args.dev, args.prod].count(True) > 1:
            Logger.error("Please specify only one environment: --test, --dev or --prod")
            exit(1)
                        
        if args.prod:
            AUTO_APPLY = False  # Disable auto-apply for production environment
        
        deploy_all = args.all
        deploy_cluster = args.cluster or deploy_all
        deploy_content = args.content or deploy_all
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
        
        if deploy_content:
            start_time = time.time()
            self.content_deploy()
            self.times.append(("content", start_time, time.time(), time.time() - start_time))
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
        if deploy_content:
            Logger.info(f"Content time: {str(round(Utils.extract_tuple_from_list(self.times, 'content')[3], 2))} seconds")
        if deploy_platform:
            Logger.info(f"Platform time: {str(round(Utils.extract_tuple_from_list(self.times, 'platform')[3], 2))} seconds")
        if deploy_challenges:
            Logger.info(f"Challenges time: {str(round(Utils.extract_tuple_from_list(self.times, 'challenges')[3], 2))} seconds")
    
    '''
    Initialize Terraform to a given environment (workspace)
    '''
    def init_terraform(self, path):
        Logger.info("Initializing Terraform")
        current_dir = os.getcwd()
        os.chdir(path)

        try:
            # Create workspaces
            Logger.info("Creating workspaces if they do not exist")
            for env in ENVIRONMENTS:
                subprocess.run([FLAVOR, "workspace", "new", env], check=False)

            # Initialize the backend (if not already done for this project)
            Logger.info("Running terraform init")
            rc = run(f"{FLAVOR} init", shell=True)
            if rc != 0:
                raise Exception
                
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
        path = Utils.get_path_to_script()
        return f"{path}/{self.get_filename_tfvars()}"
    
    '''
    Validate automated.tfvars is set, and values are set
    '''
    def check_values(self):
        # Check if automated.tfvars exists
        tfvars_path = self.get_path_tfvars()
        if not os.path.exists(tfvars_path):
            Logger.error(f"{self.get_filename_tfvars()} not found. Please create the file and try again")
            exit(1)
        
        # Ensure no < or > are present in the file
        with open(tfvars_path, "r") as file:
            for line in file:
                if "<" in line or ">" in line:
                    Logger.error(f"{self.get_filename_tfvars()} does not seem to be filled out. Please fill out all fields and try again")
                    exit(1)

        Logger.info(f"{self.get_filename_tfvars()} is filled out correctly")

    def cluster_deploy(self):
        path = Utils.get_path_to_script()
        Logger.info("Deploying the cluster")

        # Configure tfvars file
        tfvars = TFVARS(self.get_path_tfvars(), f"{path}/cluster/data.auto.tfvars")
        tfvars.create(CLUSTER_TFVARS)
        Logger.space()
        
        # Deploy the cluster
        try:
            self.init_terraform(f"{path}/cluster")
            cmd = f"cd {path}/cluster && {FLAVOR} apply {AUTO_APPLY and '-auto-approve' or ''}"
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
        path = Utils.get_path_to_script()
        Logger.info("Exporting kubeconfig")
        
        # Export kubeconfig
        try:
            rc = run(f"cd {path}/cluster && {FLAVOR} output --raw kubeconfig > {path}/kube-config/kube-config.{self.environment}.yml")
            if rc != 0:
                raise Exception
            rc = run(f"cat {path}/kube-config/kube-config.{self.environment}.yml | base64 -w0 > {path}/kube-config/kube-config.{self.environment}.b64")
            if rc != 0:
                raise Exception
        except:
            Logger.error("Failed to export kubeconfig")
        Logger.success("Kubeconfig exported")
    
    def get_kubeconfig_b64(self):
        path = Utils.get_path_to_script()
        with open(f"{path}/kube-config/kube-config.{self.environment}.b64", "r") as file:
            return file.read()
    
    def content_deploy(self):
        path = Utils.get_path_to_script()
        Logger.info("Deploying the content on the cluster")

        # Configure tfvars file
        tfvars = TFVARS(self.get_path_tfvars(), f"{path}/content/data.auto.tfvars")
        tfvars.create(CONTENT_TFVARS)
        tfvars.add("kubeconfig", self.get_kubeconfig_b64())
        tfvars.add("environment", self.environment)
        Logger.space()
        
        # Deploy the cluster
        try:
            self.init_terraform(f"{path}/content")
            rc = run(f"cd {path}/content && {FLAVOR} apply {AUTO_APPLY and '-auto-approve' or ''}", shell=True)
            if rc != 0:
                raise Exception
        except:
            Logger.error("Content apply failed")
        Logger.success("Content deployed successfully")
    
    def platform_deploy(self):
        path = Utils.get_path_to_script()
        Logger.info("Deploying the platform on the cluster")

        # Configure tfvars file
        tfvars = TFVARS(self.get_path_tfvars(), f"{path}/platform/data.auto.tfvars")
        tfvars.create(PLATFORM_TFVARS)
        tfvars.add("kubeconfig", self.get_kubeconfig_b64())
        tfvars.add("environment", self.environment)
        Logger.space()
        
        # Deploy the cluster
        try:
            self.init_terraform(f"{path}/platform")
            rc = run(f"cd {path}/platform && {FLAVOR} apply {AUTO_APPLY and '-auto-approve' or ''}", shell=True)
            if rc != 0:
                raise Exception
        except:
            Logger.error("Platform apply failed")
        Logger.success("Platform deployed successfully")

    def challenges_deploy(self):
        path = Utils.get_path_to_script()
        Logger.info("Deploying the challenges on the cluster")

        # Configure tfvars file
        tfvars = TFVARS(self.get_path_tfvars(), f"{path}/challenges/data.auto.tfvars")
        tfvars.create(CHALLENGES_TFVARS)
        tfvars.add("kubeconfig", self.get_kubeconfig_b64())
        tfvars.add("environment", self.environment)
        Logger.space()
        
        # Deploy the cluster
        try:
            self.init_terraform(f"{path}/challenges")
            rc = run(f"cd {path}/challenges && {FLAVOR} apply {AUTO_APPLY and '-auto-approve' or ''}", shell=True)
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
        self.subparser.add_argument("--content", action="store_true", help="Destroy the content")
        self.subparser.add_argument("--platform", action="store_true", help="Destroy the platform")
        self.subparser.add_argument("--challenges", action="store_true", help="Destroy the challenges")
        self.subparser.add_argument("--all", action="store_true", help="Destroy all parts of the platform")   
        self.subparser.add_argument("--test", action="store_true", help="Destroy TEST cluster (default)")
        self.subparser.add_argument("--dev", action="store_true", help="Destroy DEV cluster")
        self.subparser.add_argument("--prod", action="store_true", help="Destroy PROD cluster")     
        return

    def run(self, args):
        if not args.cluster and not args.content and not args.platform and not args.challenges and not args.all:
            Logger.error("Please specify which part of the platform to destroy")
            exit(1)
            
        if args.all and (args.cluster or args.content or args.platform or args.challenges):
            Logger.error("Please specify only --all or individual parts of the platform")
            exit(1)
            
        if [args.test, args.dev, args.prod].count(True) > 1:
            Logger.error("Please specify only one environment: --test, --dev or --prod")
            exit(1)
                        
        if args.prod:
            AUTO_APPLY = False  # Disable auto-apply for production environment
            
        destroy_all = args.all
        destroy_cluster = args.cluster or destroy_all
        destroy_content = args.content or destroy_all
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
        
        if destroy_content:
            start_time = time.time()
            self.content_destroy()
            self.times.append(("content", start_time, time.time(), time.time() - start_time))
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
        if destroy_content:
            Logger.info(f"Content time: {str(round(Utils.extract_tuple_from_list(self.times, 'content')[3], 2))} seconds")
        if destroy_platform:
            Logger.info(f"Platform time: {str(round(Utils.extract_tuple_from_list(self.times, 'platform')[3], 2))} seconds")
        if destroy_challenges:
            Logger.info(f"Challenges time: {str(round(Utils.extract_tuple_from_list(self.times, 'challenges')[3], 2))} seconds")
    
    '''
    Initialize Terraform to a given environment (workspace)
    '''
    def init_terraform(self, path):
        Logger.info("Initializing Terraform")
        current_dir = os.getcwd()
        os.chdir(path)

        try:
            # Create workspaces
            Logger.info("Creating workspaces if they do not exist")
            for env in ENVIRONMENTS:
                subprocess.run([FLAVOR, "workspace", "new", env], check=False)

            # Initialize the backend (if not already done for this project)
            Logger.info("Running terraform init")
            rc = run(f"{FLAVOR} init", shell=True)
            if rc != 0:
                raise Exception
                
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
        path = Utils.get_path_to_script()
        return f"{path}/{self.get_filename_tfvars()}"
    
    def get_kubeconfig_b64(self):
        path = Utils.get_path_to_script()
        with open(f"{path}/kube-config/kube-config.{self.environment}.b64", "r") as file:
            return file.read()
    
    def cluster_destroy(self):
        path = Utils.get_path_to_script()
        Logger.info("Destroying the cluster")
        
        
        # Configure tfvars file
        tfvars = TFVARS(self.get_path_tfvars(), f"{path}/cluster/data.auto.tfvars")
        tfvars.create(CLUSTER_TFVARS)
        Logger.space()
        
        # Destroy the cluster
        try:
            self.init_terraform(f"{path}/cluster")
            rc = run(f"cd {path}/cluster && {FLAVOR} workspace select {self.environment} && {FLAVOR} destroy {AUTO_APPLY and '-auto-approve' or ''}", shell=True)
            if rc != 0:
                raise Exception
        except:
            Logger.error("Cluster terraform destroy failed")
        
        # Remove the tfvars file
        TFVARS(self.get_path_tfvars(), f"{path}/cluster/data.auto.tfvars").destroy()
        
        Logger.success("Cluster terraform destroy applied successfully")
        
        # remove kubeconfig
        self.remove_kubeconfig()
    
    def remove_kubeconfig(self):
        path = Utils.get_path_to_script()
        Logger.info("Removing kubeconfig")
        
        # Remove kubeconfig
        try:
            rc = run(f"rm {path}/kube-config/kube-config.{self.environment}.yml", shell=True)
            if rc != 0:
                raise Exception
            rc = run(f"rm {path}/kube-config/kube-config.{self.environment}.b64", shell=True)
            if rc != 0:
                raise Exception
        except:
            Logger.error("Failed to remove kubeconfig")
        Logger.success("Kubeconfig removed")
    
    def content_destroy(self):
        path = Utils.get_path_to_script()
        Logger.info("Destroying the content on the cluster")
        
        # Configure tfvars file
        tfvars = TFVARS(self.get_path_tfvars(), f"{path}/content/data.auto.tfvars")
        tfvars.create(CONTENT_TFVARS)
        tfvars.add("kubeconfig", self.get_kubeconfig_b64())
        tfvars.add("environment", self.environment)
        Logger.space()
        
        # Destroy the content
        try:
            self.init_terraform(f"{path}/content")
            rc = run(f"cd {path}/content && {FLAVOR} workspace select {self.environment} && {FLAVOR} destroy {AUTO_APPLY and '-auto-approve' or ''}", shell=True)
            if rc != 0:
                raise Exception
        except:
            Logger.error("Content destroy failed")
        
        # Remove the tfvars file
        TFVARS(self.get_path_tfvars(), f"{path}/content/data.auto.tfvars").destroy()
        
        Logger.success("Content destroyed successfully")
    
    def platform_destroy(self):
        path = Utils.get_path_to_script()
        Logger.info("Destroying the platform on the cluster")

        # Configure tfvars file
        tfvars = TFVARS(self.get_path_tfvars(), f"{path}/platform/data.auto.tfvars")
        tfvars.create(PLATFORM_TFVARS)
        tfvars.add("kubeconfig", self.get_kubeconfig_b64())
        tfvars.add("environment", self.environment)
        Logger.space()
        
        # Destroy the platform
        try:
            self.init_terraform(f"{path}/platform")
            rc = run(f"cd {path}/platform && {FLAVOR} workspace select {self.environment} && {FLAVOR} destroy {AUTO_APPLY and '-auto-approve' or ''}", shell=True)
            if rc != 0:
                raise Exception
        except:
            Logger.error("Platform destroy failed")
        
        # Remove the tfvars file
        TFVARS(self.get_path_tfvars(), f"{path}/platform/data.auto.tfvars").destroy()
        
        Logger.success("Platform destroyed successfully")
        
    def challenges_destroy(self):
        path = Utils.get_path_to_script()
        Logger.info("Destroying the challenges on the cluster")

        # Configure tfvars file
        tfvars = TFVARS(self.get_path_tfvars(), f"{path}/challenges/data.auto.tfvars")
        tfvars.create(CHALLENGES_TFVARS)
        tfvars.add("kubeconfig", self.get_kubeconfig_b64())
        tfvars.add("environment", self.environment)
        Logger.space()
        
        # Destroy the challenges
        try:
            self.init_terraform(f"{path}/challenges")
            rc = run(f"cd {path}/challenges && {FLAVOR} workspace select {self.environment} && {FLAVOR} destroy {AUTO_APPLY and '-auto-approve' or ''}", shell=True)
            if rc != 0:
                raise Exception
        except:
            Logger.error("Challenges destroy failed")
        
        # Remove the tfvars file
        TFVARS(self.get_path_tfvars(), f"{path}/challenges/data.auto.tfvars").destroy()
        
        Logger.success("Challenges destroyed successfully")

'''
TFVars handler class
'''
class TFVARS:
    def __init__(self, root, destination):
        self.root = root
        self.destination = destination

    @staticmethod
    def get_filename_tfvars(environment="test"):
        prefix = ""
        if environment != "test":
            prefix = f"{environment}."

        return f"automated.{prefix}tfvars"
    
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
        key_value_pairs = {}
        with open(self.root, "r") as root:
            for line in root:
                line = line.strip()
                if "=" in line and not line.startswith("#"):
                    key, value = map(str.strip, line.split("=", 1))
                    key_value_pairs[key] = value

        # Filter and write only the specified fields to the destination file
        with open(self.destination, "w") as file:
            for field in fields:
                if field in key_value_pairs:
                    file.write(f"{field} = {key_value_pairs[field]}\n")
                else:
                    Logger.warning(f"Field '{field}' not found in {self.root}")
    
    def add(self, key, value):
        # Check if destionation exists
        exists = os.path.exists(self.destination)
        if not exists:
            Logger.error(f"{self.destination} does not exist")
            exit(1)
        
        # Overwrite line if it exists or append to the end
        with open(self.destination, "r") as file:
            lines = file.readlines()
        
        with open(self.destination, "w") as file:
            found = False
            for line in lines:
                if key in line:
                    file.write(f'{key} = "{value}"\n')
                    found = True
                else:
                    file.write(line)
            if not found:
                file.write(f'{key} = "{value}"\n')
    
    def destroy(self):
        # Check if destionation exists
        exists = os.path.exists(self.destination)
            
        # Remove the file
        if exists:
            Logger.info(f"Removing {self.destination}")
            os.remove(self.destination)
        else:
            Logger.info(f"{self.destination} does not exist")

    @staticmethod
    def insert_keys(environment="test"):
        path = Utils.get_path_to_script()
        
        # Read the keys
        public_key = ""
        private_key = ""
        with open(f"{path}/data/keys/k8s.pub.b64", "r") as file:
            public_key = file.read()
        with open(f"{path}/data/keys/k8s.b64", "r") as file:
            private_key = file.read()
        
        # Insert the keys into automated.tfvars
        with open(f"{path}/{TFVARS.get_filename_tfvars(environment)}", "r") as file:
            lines = file.readlines()
        with open(f"{path}/{TFVARS.get_filename_tfvars(environment)}", "w") as file:
            for line in lines:
                if "ssh_key_public_base64" in line:
                    file.write(f'ssh_key_public_base64 = "{public_key}"\n')
                elif "ssh_key_private_base64" in line:
                    file.write(f'ssh_key_private_base64 = "{private_key}"\n')
                else:
                    file.write(line)

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
