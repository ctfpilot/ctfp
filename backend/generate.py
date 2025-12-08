import os
import sys
import argparse

class Args:
    args = None
    subcommand = False
    
    def __init__(self, parent_parser = None):
        if parent_parser:
            self.subcommand = True
            self.parser = parent_parser.add_parser("generate-backend", help="Generate Terraform backend configuration")
        else:
            self.parser = argparse.ArgumentParser(description="Backend generator for Terraform")
            
        self.parser.add_argument("component", help="Component to generate backend for", choices=["cluster", "ops", "platform", "challenges"])
        self.parser.add_argument("bucket", help="S3 bucket name for Terraform state storage")
        self.parser.add_argument("region", help="Region for S3 bucket")
        self.parser.add_argument("endpoint", help="Endpoint URL for S3-compatible storage")
    
    def parse(self):
        if self.subcommand:
            self.args = self.parser.parse_args(sys.argv[2:])
        else:
            self.args = self.parser.parse_args()
        
    def __getattr__(self, name):
        return getattr(self.args, name)

class Template:
    component = None
    bucket = None
    region = None
    endpoint = None
    
    def __init__(self, component, bucket, region, endpoint):
        self.component = component
        self.bucket = bucket
        self.region = region
        self.endpoint = endpoint
        pass
    
    def replace(self, template_str, replacements):
        for key, value in replacements.items():
            template_str = template_str.replace(f"%%{key}%%", value)
        return template_str
    
    def get_template_path(self):
        base_dir = os.path.dirname(os.path.abspath(__file__))
        template_path = os.path.join(base_dir, "backend.hcl")
        return template_path
    
    def get_target_path(self):
        base_dir = os.path.dirname(os.path.abspath(__file__))
        target_dir = os.path.join(base_dir, "generated")
        if not os.path.exists(target_dir):
            os.makedirs(target_dir)
        target_path = os.path.join(target_dir, f"{self.component}.hcl")
        return target_path

    def get_template(self):
        template_path = self.get_template_path()
        with open(template_path, "r") as f:
            template_str = f.read()
        return template_str
    
    def template(self) -> str:
        template  = self.get_template()
        replacements = {
            "COMPONENT": self.component,
            "KEY": f"{self.component}.tfstate",
            "S3_BUCKET": self.bucket,
            "S3_REGION": self.region,
            "S3_ENDPOINT": self.endpoint
        }
        output = self.replace(template, replacements)
        return output
    
    def run(self):
        backend = self.template()
        target_path = self.get_target_path()
        with open(target_path, "w") as f:
            f.write(backend)
        print(f"Generated backend file at: {target_path}")
        
        
class Generator:
    args = None
    parent_parser = None

    def __init__(self, parent_parser = None):
        self.parent_parser = parent_parser
  
    def register_subcommand(self):
        self.args = Args(self.parent_parser)
  
    def run(self):
        if not self.args:
            arguments = Args(self.parent_parser)
            arguments.parse()
            self.args = arguments
        else:
            self.args.parse()
            
        args = self.args
        
        template = Template(
            component=args.component,
            bucket=args.bucket,
            region=args.region,
            endpoint=args.endpoint
        )
        template.run()

if __name__ == "__main__":
    Generator().run()