# DevOps-hng-stage-4
# Terraform & Ansible Infrastructure Deployment

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
terraform/
│── main.tf          # Defines resources and modules
│── providers.tf     # Configures AWS provider
│── variables.tf     # Defines input variables
│── output.tf        # Outputs values after deployment
│── terraform.tfvars # Stores variable values
│── templates/       # Stores Ansible inventory templates
│── .terraform/      # Terraform plugin cache (generated)
│── .terraform.lock.hcl # Dependency lock file
│── ansible/
    │── playbook.yml # Ansible automation script
    │── roles/       # Ansible roles (dependencies, deployment)
    │── vars/        # Variable definitions
```

## Setup and Deployment

### 1. Initialize Terraform
Run the following command to initialize the Terraform environment:
```sh
terraform init
```

### 2. Validate Terraform Configuration
Ensure the configuration is valid:
```sh
terraform validate
```

### 3. Plan Deployment
Preview the changes Terraform will apply:
```sh
terraform plan
```

### 4. Apply Deployment
Deploy the infrastructure:
```sh
terraform apply -auto-approve
```

### 5. Run Ansible Playbook
Once Terraform completes, use Ansible to configure instances:
```sh
ansible-playbook -i inventory playbook.yml
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



