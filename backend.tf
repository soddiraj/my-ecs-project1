# Terraform Cloud/Enterprise Backend Configuration
# This stores your Terraform state in Terraform Cloud

terraform {
  backend "remote" {
    hostname     = "app.terraform.io"  # Use your TFE hostname if using Terraform Enterprise
    organization = "soddiraju"  # Replace with your Terraform Cloud organization name

    workspaces {
      name = "my-ecs-project1"  # Replace with your desired workspace name
    }
  }
}

# Alternative: Use tags to select workspace dynamically
# terraform {
#   backend "remote" {
#     hostname     = "app.terraform.io"
#     organization = "YOUR_ORGANIZATION_NAME"
#
#     workspaces {
#       tags = ["aws", "ecs", "nginx"]
#     }
#   }
# }

# Alternative: Use prefix for multiple workspaces
# terraform {
#   backend "remote" {
#     hostname     = "app.terraform.io"
#     organization = "YOUR_ORGANIZATION_NAME"
#
#     workspaces {
#       prefix = "nginx-ecs-"  # Will create workspaces like: nginx-ecs-dev, nginx-ecs-prod
#     }
#   }
# }
