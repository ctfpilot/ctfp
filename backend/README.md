# Backend Terraform Configuration Generator

This script generates Terraform backend configuration files for different components of CTFp.

## Usage

To generate a backend configuration file, run the script with the required arguments:

```bash
python generate.py <component> <bucket> <region> <endpoint>
```

It will create a backend configuration file in the `generated` directory.

This can be used when initializing Terraform for the respective component:

```bash
tofu init -backend-config=../backend/generated/<component>.hcl
```

### Arguments

- `<component>`: The component for which to generate the backend configuration. Valid options are `cluster`, `ops`, `platform`, and `challenges`.
- `<bucket>`: The S3 bucket name where the Terraform state will be stored.
- `<region>`: The region of the S3 bucket.
- `<endpoint>`: The endpoint URL for the S3-compatible storage.
