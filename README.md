# NGINX on ECS Fargate with ALB - Terraform Project

This Terraform project creates a complete AWS infrastructure to run an NGINX container on ECS Fargate with an Application Load Balancer.

## Architecture

The infrastructure includes:

- **VPC**: Custom VPC with CIDR 10.0.0.0/16
- **Subnets**: 
  - 2 Public subnets (10.0.1.0/24, 10.0.2.0/24)
  - 2 Private subnets (10.0.11.0/24, 10.0.12.0/24)
- **NAT Gateway**: Single NAT Gateway in the first public subnet (cost-optimized)
- **Internet Gateway**: For public subnet internet access
- **Application Load Balancer**: In public subnets
- **ECS Fargate Cluster**: Running NGINX containers in private subnets
- **Security Groups**: Proper security configurations for ALB and ECS tasks

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- AWS Account with appropriate permissions
- AWS CLI configured with credentials

## File Structure

```
.
├── main.tf              # Provider configuration
├── variables.tf         # Variable definitions
├── vpc.tf              # VPC, subnets, NAT gateways, route tables
├── security_groups.tf  # Security groups for ALB and ECS
├── alb.tf              # Application Load Balancer configuration
├── ecs.tf              # ECS cluster, task definition, and service
├── outputs.tf          # Output values
├── backend.tf          # Terraform Cloud backend configuration
├── terraform.tfvars.example  # Example variables file
├── TERRAFORM_CLOUD_SETUP.md  # Terraform Cloud setup guide
└── README.md           # This file
```

## Backend Options

This project supports multiple backend configurations:

### Option 1: Local Backend (Default)
State files are stored locally in your project directory. Good for learning and single-user development.

```bash
# Just run terraform as usual
terraform init
terraform apply
```

### Option 2: Terraform Cloud/Enterprise (Recommended for Teams)
Remote state storage with collaboration features. See [TERRAFORM_CLOUD_SETUP.md](TERRAFORM_CLOUD_SETUP.md) for detailed setup.

1. Create Terraform Cloud account at https://app.terraform.io
2. Update `backend.tf` with your organization and workspace name
3. Run `terraform login` to authenticate
4. Initialize: `terraform init`

**Quick Setup:**
```bash
# Login to Terraform Cloud
terraform login

# Edit backend.tf with your organization name
# Then initialize
terraform init
```

📖 **Full guide**: See [TERRAFORM_CLOUD_SETUP.md](TERRAFORM_CLOUD_SETUP.md)

## Usage

### 1. Clone or navigate to the project directory

```bash
cd /Users/sharathoddiraju/myspace/learnings/Project-1
```

### 2. Configure AWS credentials

Make sure your AWS credentials are configured:

```bash
aws configure
```

### 3. (Optional) Customize variables

Create a `terraform.tfvars` file if you want to customize any values:

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your preferred values
```

### 4. Initialize Terraform

```bash
terraform init
```

### 5. Review the execution plan

```bash
terraform plan
```

### 6. Apply the configuration

```bash
terraform apply
```

Type `yes` when prompted to confirm.

### 7. Access the application

After successful deployment (takes about 5-10 minutes), Terraform will output the ALB DNS name:

```bash
terraform output alb_url
```

Open the URL in your browser to see the NGINX welcome page.

## Testing the Application

Once deployed, you can access your NGINX application using the ALB DNS name:

```bash
# Get the ALB URL
terraform output alb_url

# Test with curl
curl $(terraform output -raw alb_url)
```

You should see the default NGINX welcome page.

## Important Notes

1. **Costs**: This infrastructure includes a NAT Gateway which incurs hourly charges (~$0.045/hour). Remember to destroy resources when done testing.

2. **Cost Optimization**: The setup uses a single NAT Gateway shared by both private subnets for cost savings. For production high-availability, consider using one NAT Gateway per availability zone.

2. **Deployment Time**: Initial deployment takes approximately 5-10 minutes due to:
   - VPC and networking setup
   - NAT Gateway provisioning
   - ECS task startup and health checks

3. **Health Checks**: The ALB performs health checks on the `/` path. Tasks will only receive traffic once they pass health checks.

## Cleanup

To avoid ongoing AWS charges, destroy the infrastructure when you're done:

```bash
terraform destroy
```

Type `yes` when prompted to confirm.

## Customization

### Change the Region

Edit `variables.tf` or create a `terraform.tfvars` file:

```hcl
aws_region = "us-west-2"
```

### Change the Number of Tasks

```hcl
desired_count = 3
```

### Use a Different Container Image

```hcl
container_image = "your-registry/your-image:tag"
```

### Adjust CPU and Memory

```hcl
cpu    = "512"
memory = "1024"
```

## Troubleshooting

### Tasks not starting

1. Check ECS service events:
   ```bash
   aws ecs describe-services --cluster nginx-ecs-cluster --services nginx-ecs-service --region us-east-1
   ```

2. Check CloudWatch logs:
   ```bash
   aws logs tail /ecs/nginx-ecs --follow --region us-east-1
   ```

### ALB health checks failing

1. Verify security group rules allow traffic from ALB to ECS tasks
2. Check that the container is listening on the correct port (80)
3. Review target group health status in AWS Console

### Cannot access the application

1. Wait a few minutes for tasks to become healthy
2. Verify the ALB security group allows inbound traffic on port 80
3. Check that tasks are registered with the target group

## Outputs

After successful deployment, the following outputs are available:

- `vpc_id`: The VPC ID
- `public_subnet_ids`: List of public subnet IDs
- `private_subnet_ids`: List of private subnet IDs
- `alb_dns_name`: The DNS name of the ALB
- `alb_url`: The complete URL to access the application
- `ecs_cluster_name`: Name of the ECS cluster
- `ecs_service_name`: Name of the ECS service

View all outputs:

```bash
terraform output
```

## Architecture Diagram

```
Internet
    |
    v
Internet Gateway
    |
    v
Application Load Balancer (Public Subnets x2)
    |
    v
ECS Tasks (NGINX) (Private Subnets x2)
    |
    v
NAT Gateway (Single, in Public Subnet 1) --> Internet
```

## License

This is a learning project and is free to use for educational purposes.
