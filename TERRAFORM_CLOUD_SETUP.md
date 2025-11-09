# Terraform Cloud Setup Guide

This guide helps you configure Terraform Cloud backend for remote state management.

## Prerequisites

- Terraform Cloud account (free tier available at https://app.terraform.io)
- Terraform CLI installed locally
- AWS credentials

---

## Step 1: Create Terraform Cloud Account

1. Go to https://app.terraform.io
2. Sign up for a free account
3. Create an organization (e.g., "my-org")

---

## Step 2: Create a Workspace

### Option A: Via Terraform Cloud UI

1. Log in to Terraform Cloud
2. Click **New Workspace**
3. Choose **CLI-driven workflow**
4. Name your workspace: `nginx-ecs-fargate`
5. Click **Create workspace**

### Option B: Via CLI (Automatic)

The workspace will be created automatically when you run `terraform init` with the backend configured.

---

## Step 3: Configure AWS Credentials in Terraform Cloud

### In your workspace:

1. Go to your workspace → **Variables**
2. Add the following **Environment Variables**:

   | Variable Name | Value | Sensitive? | Category |
   |---------------|-------|------------|----------|
   | `AWS_ACCESS_KEY_ID` | Your AWS access key | ✅ Yes | env |
   | `AWS_SECRET_ACCESS_KEY` | Your AWS secret key | ✅ Yes | env |
   | `AWS_DEFAULT_REGION` | `us-east-1` | ❌ No | env |

3. **Terraform Variables** (optional, if not using terraform.tfvars):

   | Variable Name | Value | HCL? | Category |
   |---------------|-------|------|----------|
   | `aws_region` | `us-east-1` | ❌ No | terraform |
   | `project_name` | `nginx-demo-ecs` | ❌ No | terraform |
   | `desired_count` | `2` | ❌ No | terraform |

---

## Step 4: Authenticate Terraform CLI

### Method 1: Using terraform login (Recommended)

```bash
terraform login
```

This will:
1. Open a browser to generate a token
2. Save the token to `~/.terraform.d/credentials.tfrc.json`

### Method 2: Manual Token Creation

1. Go to Terraform Cloud → **User Settings** → **Tokens**
2. Click **Create an API token**
3. Copy the token
4. Create/edit `~/.terraform.d/credentials.tfrc.json`:

```json
{
  "credentials": {
    "app.terraform.io": {
      "token": "YOUR_TERRAFORM_CLOUD_TOKEN"
    }
  }
}
```

---

## Step 5: Update backend.tf

Edit `backend.tf` and replace:

```hcl
terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "YOUR_ORGANIZATION_NAME"  # ← Change this

    workspaces {
      name = "nginx-ecs-fargate"  # ← Change this if needed
    }
  }
}
```

**Example:**
```hcl
terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "mycompany"

    workspaces {
      name = "nginx-ecs-fargate"
    }
  }
}
```

---

## Step 6: Initialize Terraform with Remote Backend

```bash
# Navigate to your project
cd /Users/sharathoddiraju/myspace/learnings/Project-1

# Initialize with the remote backend
terraform init

# If you have existing local state, Terraform will ask if you want to migrate
# Type 'yes' to copy your local state to Terraform Cloud
```

---

## Step 7: Run Terraform Commands

### Plan
```bash
terraform plan
```

### Apply
```bash
terraform apply
```

### View State
```bash
terraform show
```

All commands will now use the remote state stored in Terraform Cloud!

---

## Workspace Configuration Options

### Option 1: Single Workspace (Simplest)

```hcl
workspaces {
  name = "nginx-ecs-fargate"
}
```

### Option 2: Multiple Environments with Prefix

```hcl
workspaces {
  prefix = "nginx-ecs-"
}
```

Select workspace:
```bash
terraform workspace select nginx-ecs-dev
terraform workspace select nginx-ecs-prod
```

### Option 3: Tag-based Selection

```hcl
workspaces {
  tags = ["aws", "ecs", "nginx"]
}
```

---

## Terraform Cloud Execution Modes

### Local Execution (Default for CLI-driven)
- Terraform runs on your local machine
- Only state is stored remotely
- Fast and simple

### Remote Execution
- Terraform runs in Terraform Cloud
- Useful for team collaboration
- Consistent execution environment

To enable remote execution:
1. Go to workspace → **Settings** → **General**
2. Change **Execution Mode** to **Remote**

---

## Benefits of Terraform Cloud Backend

✅ **Remote State Storage**: Secure and versioned state
✅ **State Locking**: Prevents concurrent modifications
✅ **Collaboration**: Team members can access the same state
✅ **Workspace History**: Track all changes and runs
✅ **VCS Integration**: Connect to GitHub/GitLab/Azure Repos
✅ **Cost Estimation**: Preview infrastructure costs
✅ **Policy as Code**: Sentinel policies (paid tier)

---

## Migration from Local State

If you already have a local `terraform.tfstate`:

```bash
# Initialize with new backend
terraform init

# Terraform will detect existing state and ask:
# "Do you want to copy existing state to the new backend?"
# Type: yes

# Verify migration
terraform state list
```

---

## Troubleshooting

### Error: "No valid credential sources found"

**Solution**: Run `terraform login` or check your credentials file.

### Error: "Organization not found"

**Solution**: Verify the organization name in `backend.tf` matches your Terraform Cloud organization.

### Error: "Workspace not found"

**Solution**: Either create the workspace in Terraform Cloud UI first, or let Terraform create it automatically during `terraform init`.

### Error: "State lock timeout"

**Solution**: 
1. Check if another run is in progress in Terraform Cloud
2. Force unlock if needed:
   ```bash
   terraform force-unlock LOCK_ID
   ```

---

## Switching Back to Local Backend

If you want to switch back to local state:

1. Comment out or remove the `backend "remote"` block from `backend.tf`
2. Run:
   ```bash
   terraform init -migrate-state
   ```
3. Type `yes` to copy state from Terraform Cloud to local

---

## Best Practices

1. **Use separate workspaces** for dev, staging, production
2. **Enable state locking** (automatic with Terraform Cloud)
3. **Use variable sets** for shared variables across workspaces
4. **Set up notifications** for run status (Slack, email)
5. **Use VCS-driven workflow** for production (connect to Git)
6. **Enable team access controls** (paid plans)

---

## Alternative: S3 Backend

If you prefer AWS S3 backend instead:

```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "nginx-ecs/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

---

## Next Steps

After setting up Terraform Cloud backend:

1. ✅ Configure workspace variables
2. ✅ Run `terraform init` to migrate state
3. ✅ Run `terraform plan` to verify
4. ✅ Run `terraform apply` to deploy
5. ✅ Check run history in Terraform Cloud UI
6. ✅ Set up VCS integration (optional)

---

## Useful Commands

```bash
# Login to Terraform Cloud
terraform login

# Logout
terraform logout

# List workspaces
terraform workspace list

# Select workspace
terraform workspace select <name>

# Show current workspace
terraform workspace show

# View state in remote backend
terraform state list
```

---

## Resources

- [Terraform Cloud Documentation](https://developer.hashicorp.com/terraform/cloud-docs)
- [CLI-driven Workflow](https://developer.hashicorp.com/terraform/cloud-docs/run/cli)
- [Remote Backend](https://developer.hashicorp.com/terraform/language/settings/backends/remote)
- [Terraform Cloud Pricing](https://www.hashicorp.com/products/terraform/pricing)

---

Happy Terraforming! 🚀
