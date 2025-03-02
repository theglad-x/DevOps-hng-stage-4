# Microservices TODO Application - Infrastructure Deployment
## Overview
This repository contains Terraform and Ansible configurations for provisioning cloud infrastructure and deploying a containerized application stack.

## Prerequisites
Ensure you have the following installed:
- Terraform (>= 1.0.0)
- Ansible (>= 2.10)
- AWS CLI (configured with credentials)
- Docker & Docker Compose

## Project Structure
```
terraform-todo-deployment/
├── main.tf
├── variables.tf
├── terraform.tfvars
├── templates/
│   ├── inventory.tmpl
│   └── vars.tmpl
└── ansible/
    ├── inventory/
    │   └── .gitkeep
    ├── vars/
    │   └── .gitkeep
    ├── playbook.yml
    └── roles/
        ├── dependencies/
        │   └── tasks/
        │       └── main.yml
        └── deployment/
            ├── tasks/
            │   └── main.yml
            └── templates/
                ├── docker-compose.yml.j2
                ├── dynamic.yaml.j2
                └── env.j2 
```

## Setup and Deployment

### 1. Clone the Repository
```sh
git clone https://github.com/theglad-x/DevOps-hng-stage-4.git
cd DevOps-hng-stage-4-infra
cd terraform 
```
### 2. Modifying Application Deployment
To deploy application:

1. Update the repository URL in terraform.tfvars
2. Modify docker-compose.yml.j2 to match the application requirements
3. Update environment variables in env.j2

### 3. Configure Environment Variables
Edit terraform.tfvars file in the terraform directory:
```sh
aws_region       = "us-east-1"
instance_type    = "t2.medium"
key_name         = "your-keypair"
domain_name      = "your-domain.com"
route53_zone_id  = "Z1234567890ABCDEFGHIJ"
admin_email      = "xxxxx@email.com"
git_repo_url     = "https://github.com/your-project/repo"
git_branch       = "main"
```

### 4. Format Terraform code
```sh
terraform fmt
```

### 5. Initialize Terraform
Run the following command to initialize the Terraform environment:
```sh
terraform init
```

### 6. Validate Terraform Configuration
Ensure the configuration is valid:
```sh
terraform validate
```

### 7. Plan Deployment
Preview the changes Terraform will apply:
```sh
terraform plan
```

### 8. Apply Deployment
Deploy the infrastructure:
```sh
terraform apply -auto-approve
```

## Troubleshooting
### Terraform Provider Errors
If you encounter a **"Failed to load plugin schemas"** error:
1. Ensure you have an active internet connection.
2. Run:
```sh
   terraform init -upgrade
```
3. If the issue persists, delete the `.terraform` directory and reinitialize:
   
```sh
   rm -rf .terraform
   terraform init
```

### AWS Authentication Issues
Ensure that your AWS credentials are correctly configured. Check by running:
```sh
aws sts get-caller-identity
```

## Cleanup
To destroy all infrastructure created by Terraform, run:
```sh
terraform destroy -auto-approve
```

## Contributing
1. Fork the repository
2. Create a feature branch
3. Feel free to submit a Pull Request.

## License
This project is licensed under the MIT License.
