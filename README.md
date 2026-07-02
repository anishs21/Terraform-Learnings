# Terraform AWS – HashiCorp Standard Files

> These are the 5 standard files every AWS Terraform project typically contains.

---

## 📁 File Structure

```
├── provider.tf
├── variables.tf
├── terraform.tfvars
├── main.tf
└── output.tf
```

---

## 1. provider.tf
Declares the AWS provider plugin and version required by Terraform.

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# Multi-region example (using alias)
provider "aws" {
  alias  = "region-2"
  region = "us-east-1"
}
```

---

## 2. variables.tf
Declares all input variables with type, description, and optional defaults.

```hcl
variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
  # No default — required, Terraform will prompt if not supplied
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

# Example: second instance variables
variable "ami_id_1" {
  description = "AMI ID for second instance"
  type        = string
}

variable "instance_type_1" {
  description = "Instance type for second instance"
  type        = string
}

# Example: sensitive variable (masked in logs)
variable "db_password" {
  description = "RDS database password"
  type        = string
  sensitive   = true
  default     = null
}
```

---

## 3. terraform.tfvars
Supplies actual values for the declared variables. This file is auto-loaded by Terraform.

```hcl
region        = "ap-south-1"
ami_id        = "ami-0b6d9d3d33ba97d99"
instance_type = "t3.medium"

# Second instance (different region)
ami_id_1        = "ami-01a00762f46d584a1"
instance_type_1 = "t2.medium"
```

> ⚠️ Do NOT commit `terraform.tfvars` to GitHub if it contains sensitive values like passwords or secret keys. Add it to `.gitignore`.

---

## 4. main.tf
Defines the actual AWS resources to be created. References input variables using `var.<name>`.

```hcl
# Primary instance (ap-south-1 — default provider)
resource "aws_instance" "Test-instance" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name = "Test-instance-1"
  }
}

# Second instance (us-east-1 — aliased provider)
resource "aws_instance" "Test-instance-2" {
  ami           = var.ami_id_1
  instance_type = var.instance_type_1
  provider      = aws.region-2

  tags = {
    Name = "Test-instance-2"
  }
}
```

---

## 5. output.tf
Exposes resource attribute values after `terraform apply` completes.
Read-only — values come from AWS, not from the user.

```hcl
output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.Test-instance.id
}

output "public_ip" {
  description = "Public IP of EC2 instance"
  value       = aws_instance.Test-instance.public_ip
}

output "instance_2_public_ip" {
  description = "Public IP of second EC2 instance"
  value       = aws_instance.Test-instance-2.public_ip
}
```

---

## 6. Run Order

Always follow this order when working with Terraform:

```bash
terraform init      # Download AWS provider plugin
terraform plan      # Preview what will be created (no changes made)
terraform apply     # Actually create resources in AWS
terraform destroy   # Delete all resources managed by this config
```

---

## 7. File Summary

| File | Purpose | Key Point |
|------|---------|-----------|
| `provider.tf` | AWS provider config | Sets region, alias, version |
| `variables.tf` | Variable declarations | Type + description + default |
| `terraform.tfvars` | Variable values | Auto-loaded by Terraform |
| `main.tf` | Resource definitions | What gets created in AWS |
| `output.tf` | Expose resource values | Read after apply completes |
