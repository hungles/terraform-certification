# Terraform Certification Project

This repository contains Infrastructure as Code (IaC) for AWS using Terraform, organized as a modular and scalable project structure designed for certification and best practices learning.

## Project Overview

This project demonstrates Terraform best practices including:
- **Modular architecture** with reusable modules
- **Dynamic CI/CD pipelines** using GitHub Actions
- **Remote state management** with S3 backend and DynamoDB locking
- **Multi-environment support** (dev stack)
- **Automatic resource detection** for selective deployments

## Repository Structure

```
terraform-certification/
├── dev/                              # Development environment
│   ├── instances/                    # EC2 instances stack
│   │   ├── main.tf
│   │   ├── providers.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── terraform.tfstate
│   └── network/                      # VPC and networking stack
│       ├── main.tf
│       ├── providers.tf
│       ├── variables.tf
│       ├── dev-variables.tfvars      # Dev-specific variable values
│       └── terraform.tfstate
├── modules/                          # Reusable Terraform modules
│   ├── ec2/                          # EC2 instance module
│   │   ├── main.tf
│   │   └── variables.tf
│   └── vpc/                          # VPC and subnets module
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
└── .github/workflows/                # GitHub Actions workflows
    ├── terraform.yml                 # Main CI/CD pipeline
    └── terraform-destroy.yml         # Manual destroy workflow
```

## Prerequisites

- **Terraform**: v1.8.5 or higher
- **AWS Account**: with appropriate permissions for EC2, VPC, and IAM
- **AWS CLI**: configured with credentials
- **Git**: for version control
- **GitHub Secrets**: configured for CI/CD

## Local Setup

### 1. Clone the Repository

```bash
git clone https://github.com/hungles/terraform-certification.git
cd terraform-certification
```

### 2. Configure AWS Credentials

```bash
export AWS_REGION=us-east-1
export AWS_ACCESS_KEY_ID=your_access_key
export AWS_SECRET_ACCESS_KEY=your_secret_key
```

### 3. Initialize Terraform (Local)

For **dev/network**:
```bash
cd dev/network
terraform init \
  -backend-config="bucket=YOUR_BUCKET" \
  -backend-config="key=dev/network/terraform.tfstate" \
  -backend-config="region=us-east-1" \
  -backend-config="encrypt=true"
```

For **dev/instances**:
```bash
cd dev/instances
terraform init \
  -backend-config="bucket=YOUR_BUCKET" \
  -backend-config="key=dev/instances/terraform.tfstate" \
  -backend-config="region=us-east-1" \
  -backend-config="encrypt=true"
```

## Deployment

### Local Deployment

#### Network Stack (with tfvars)
```bash
cd dev/network
terraform plan -var-file="dev-variables.tfvars" -var="aws_region=us-east-1"
terraform apply -var-file="dev-variables.tfvars" -var="aws_region=us-east-1"
```

#### Instances Stack
```bash
cd dev/instances
terraform plan -var="aws_region=us-east-1"
terraform apply -var="aws_region=us-east-1"
```

### GitHub Actions Deployment

The project uses **automatic change detection**. When you push changes:

1. **Format Check**: Validates Terraform formatting
2. **Validation**: Checks syntax and configuration
3. **Plan**: Generates an execution plan
4. **Apply**: Applies changes (manual trigger or merge to main)

**Workflow triggers:**
- Pull requests with `**/*.tf` or `.github/workflows/terraform.yml` changes
- Pushes to `main` or `dev` branches
- Manual trigger via `workflow_dispatch`

## GitHub Actions Configuration

### Required Secrets

Add these secrets to your GitHub repository (`Settings > Secrets and variables > Actions`):

```
AWS_ACCESS_KEY_ID          # AWS access key
AWS_SECRET_ACCESS_KEY      # AWS secret key
AWS_REGION                 # AWS region (default: us-east-1)
TF_STATE_BUCKET            # S3 bucket name for remote state
TF_STATE_LOCK_TABLE        # DynamoDB table for state locking (optional)
```

### Workflows

#### Main Pipeline (`terraform.yml`)
- Automatically detects changed Terraform files
- Determines the working directory dynamically
- Runs format check, validation, plan, and apply
- Only applies on pushes to `main` or manual trigger

#### Destroy Pipeline (`terraform-destroy.yml`)
- Manual trigger via GitHub Actions
- Requires confirmation (type "DESTROY")
- Choose specific stack or destroy all
- Safely tears down infrastructure with approval

## Key Features

### Dynamic Working Directory Detection

The workflow automatically:
1. Detects which Terraform files changed
2. Determines the parent directory
3. Uses only that directory for validation and deployment

Example:
- Change `dev/network/main.tf` → workflow uses `dev/network` only
- Change `dev/instances/variables.tf` → workflow uses `dev/instances` only

### Variable File Handling

The workflow searches for `*.tfvars` or `*.tfvars.json` files:
- If found, passes it with `-var-file=`
- If not found, uses only `-var=` arguments
- Supports multiple environments with different tfvars

### Remote State Management

- **Backend**: S3 with encryption
- **Locking**: DynamoDB table (optional but recommended)
- **State keys**: Organized by stack (`dev/network/terraform.tfstate`, etc.)

## Destroying Infrastructure

### Destroy via GitHub Actions

```
1. Go to Actions > Terraform Destroy
2. Click "Run workflow"
3. Enter:
   - confirm_destroy: "DESTROY"
   - target: "all" (or "dev/instances" / "dev/network")
4. Confirm
```

### Destroy Locally

```bash
cd dev/network
terraform destroy -var-file="dev-variables.tfvars" -var="aws_region=us-east-1"
```

## Modules

### VPC Module (`modules/vpc`)
Creates:
- VPC with configurable CIDR
- Public and private subnets across multiple AZs
- NAT Gateway (optional)
- VPN Gateway (optional)
- DNS hostnames and support enabled

**Variables:**
- `vpc_name`: VPC name
- `vpc_cidr`: VPC CIDR block
- `availability_zones`: List of AZs
- `public_subnets`: List of public subnet CIDRs
- `private_subnets`: List of private subnet CIDRs
- `enable_nat_gateway`: Enable NAT Gateway
- `enable_vpn_gateway`: Enable VPN Gateway

### EC2 Module (`modules/ec2`)
Creates:
- EC2 instances in specified subnets
- Uses terraform-aws-modules for best practices
- Supports multiple instances

## Variables File Example

**dev/network/dev-variables.tfvars:**
```hcl
vpc_name            = "dev-vpc"
vpc_cidr            = "10.0.0.0/16"
availability_zones  = ["us-east-1a", "us-east-1b", "us-east-1c"]
public_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnets     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
public_subnet_tags  = { Tier = "Public", Environment = "Dev" }
private_subnet_tags = { Tier = "Private", Environment = "Dev" }
```

## Troubleshooting

### Missing Region Error
```
Error: The "region" attribute or the "AWS_REGION" or "AWS_DEFAULT_REGION" environment variables must be set.
```

**Solution:**
```bash
export AWS_REGION=us-east-1
export AWS_DEFAULT_REGION=us-east-1
```

### Backend Configuration Issues
```
Error: Missing region value
```

**Solution:** Always pass backend config parameters during `terraform init`:
```bash
terraform init -backend-config="region=us-east-1" ...
```

### No Changes to Deploy
If destroy shows "Resources: 0 destroyed", verify:
- Remote state key is correct
- S3 bucket exists and is accessible
- State file contains resources

## Best Practices

1. **Always use tfvars** for environment-specific values
2. **Enable state locking** with DynamoDB
3. **Use remote state** for team collaboration
4. **Review plans** before applying
5. **Tag resources** for cost tracking and organization
6. **Version modules** with appropriate constraints
7. **Keep secrets** in GitHub Secrets, not in code
8. **Use branches** for feature development and PRs for review

## Contributing

1. Create a feature branch
2. Make changes and test locally
3. Push and create a Pull Request
4. Review the Terraform plan in the workflow
5. Merge when approved
6. Deploy via main branch or manual trigger

## License

This project is for certification and educational purposes.

## Support

For issues or questions:
1. Check the [Terraform AWS documentation](https://registry.terraform.io/providers/hashicorp/aws/latest)
2. Review GitHub Actions logs for workflow details
3. Verify AWS credentials and permissions
4. Check S3 bucket and DynamoDB access

---

**Last Updated:** July 9, 2026  
**Terraform Version:** 1.8.5  
**AWS Provider Version:** ~> 6.37.0 (instances), ~> 5.0 (network)
