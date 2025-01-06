# GitHub Actions Pipeline

### Part 1: Initial Setup and Configuration

#### Refresh AWS Access Keys
- Return to the AWS access portal
- Refresh the page
- Copy the updated Access keys

#### Fork the Repository
- Go to the repository page
- Click the "Fork" button in the top right
- Select your account as the destination

### Part 2: GitHub and AWS Configuration

#### Add GitHub Repository Secrets
- Go to your forked repository's Settings
- Click "Secrets and variables" → "Actions"
- Click "New repository secret"
- Add two secrets:
  ```
  Name: AWS_ACCESS_KEY_ID
  Value: (your access key from step 3)
  
  Name: AWS_SECRET_ACCESS_KEY
  Value: (your secret key from step 3)

  Name: AWS_SESSION_TOKEN
  Value: (your session token from step 3)
  ```

#### Create GitHub Environment
- Go to repository Settings → Environments
- Click "New environment"
- Name it: gh-actions-lab
- Enable "Required reviewers"
- Add your GitHub username as a required reviewer
- Save protection rules

### Part 3: AWS Configuration

#### Create S3 Backend
- Log into AWS Console
- Navigate to S3 service
- Click "Create bucket"
- Create a globally unique bucket name by adding your username or another unique identifier
  (e.g., `my-terraform-state-bucket-johndoe123`)
- Region should be "us-west-1"
- Keep all other settings as default
- Click "Create bucket"
- If you get an error that the bucket name already exists, try a different unique suffix
- Remember the bucket name you used

### Part 4: Repository Configuration

#### Clone and Create Feature Branch
- Clone your forked repository:
  ```bash
  git clone https://github.com/YOUR-USERNAME/REPO-NAME.git
  cd REPO-NAME
  ```
- Create and checkout a new feature branch:
  ```bash
  git checkout -b feature/github-actions-lab
  ```

#### Update Backend Configuration
- Open labs/gh-actions/main/backend.tf
- Update the bucket name to match your created bucket:
  ```hcl
  terraform {
    backend "s3" {
      bucket = "your-actual-bucket-name"
      key    = "dev/terraform.tfstate"
      region = "us-west-1"
    }
  }
  ```
#### Commit and Push Changes
- Stage and commit your changes:
  ```bash
  git add .
  git commit -m "Update S3 backend configuration"
  ```
- Push your feature branch to GitHub:
  ```bash
  git push -u origin feature/github-actions-lab
  ```
- Go to the Actions tab in GitHub
- Notice that no workflow is running yet - this is because there is no trigger configured for this branch.

#### Configure Pipeline Trigger
- Open `.github/workflows/terraform-plan-apply.yml`
- Add feature branch trigger to the `on` section:
  ```yaml
  on:
    push:
      branches: [ "feature/**" ]
    workflow_dispatch:
  ```
- Commit and push the changes:
  ```bash
  git add .
  git commit -m "Add feature branch trigger to workflow"
  git push
  ```

### Part 5: Deployment and Verification

#### Deploy Infrastructure
- Navigate to the Actions tab in GitHub
- You should now see the workflow running for your feature branch
- Watch the pipeline run through the plan stage
- When prompted, carefully review the Terraform plan. You should see:
  - 7 resources to add
  - 0 resources to change
  - 0 resources to destroy
- If the numbers don't match exactly, stop and review your configuration
- Click on the "Approve Terraform Plan" job to review the details
- Click "Review deployments"
- Click "Approve and deploy" only after confirming the correct resource count

#### Verify Deployment
- Wait for the terraform apply job to complete
- Get the public IP:
  1. Go to the AWS Console
  2. Navigate to EC2 → Instances
  3. Find the instance named "web-server"
  4. Copy its public IPv4 address
- Open the IP in your web browser
- You should see: "Welcome to the GitHub Actions & Terraform Lab!!"

### Part 6: Update Instance Type

#### Modify Pipeline Configuration
- Open `.github/workflows/terraform-plan-apply.yml`
- Locate the `env` section at the top of the file
- Add the instance type variable:
  ```yaml
  env:
    TERRAFORM_DIR: './main'
    TF_VAR_instance_type: 't2.small'
  ```
- Commit and push your changes:
  ```bash
  git add .
  git commit -m "Update instance type to t2.small"
  git push
  ```

#### Verify Instance Type Change
- Go to the Actions tab in GitHub
- Watch the new workflow run
- Review the Terraform plan carefully. You should see:
  - 0 resources to add
  - 1 resource to change (the EC2 instance)
  - 0 resources to destroy
- Verify that the only modification is the instance_type changing from t2.micro to t2.small
- Approve the deployment
- After successful deployment:
  - Get the new IP address from AWS Console (EC2 → Instances → web-server → Public IPv4 address)
  - Verify the application works by accessing this new IP in your browser
  - Confirm in the AWS Console that the instance is now running on t2.small

### Part 7: Configure Cleanup Workflow

#### Add PR Merge Trigger for Destroy
- Open `.github/workflows/terraform-destroy.yml`
- Add pull request trigger to the `on` section:
  ```yaml
  on:
    workflow_dispatch:
    pull_request:
      types: [opened]
      branches: [main]
  ```
- Commit and push your changes:
  ```bash
  git add .
  git commit -m "Add PR merge trigger to destroy workflow"
  git push
  ```

#### Verify Cleanup Configuration
- Create a PR from your feature branch to the main branch
- Wait for the destroy workflow to trigger automatically (this happens when PR is opened)
- When prompted, carefully review the Terraform destroy plan. You should see:
  - 0 resources to add
  - 0 resources to change
  - 7 resources to destroy
- If the numbers don't match exactly, stop and investigate
- Review and approve the destroy plan only after confirming all 7 resources will be destroyed
- Verify all resources are successfully destroyed in AWS Console
- Once destruction is confirmed, merge the PR
- Verify in AWS Console that the environment remains cleaned up after merge

### Completion

Congratulations on completing the GitHub Actions and Terraform integration lab! You've successfully configured and executed workflows to manage infrastructure as code, which included planning, applying, and destroying AWS resources based on changes in your repository.

### Lab Summary:
- You configured the Terraform environment and variables.
- You modified instance types and triggered workflows through commits and pull requests.
- You added triggers for cleanup workflows to ensure resources are destroyed when pull requests are closed.
- You verified changes and cleanup through the GitHub Actions tab and AWS Console.

This hands-on experience is crucial for mastering DevOps practices and understanding the power of automation in cloud infrastructure management.

### Troubleshooting Guide

#### Common Issues and Solutions

##### Bucket Creation Issues
- "Bucket already exists" error:
  - Add a unique suffix to the bucket name (e.g., my-terraform-state-bucket-username)

##### Approval Issues
- Approval step not appearing:
  - Verify environment name is exactly "gh-actions-lab"
  - Check that you added yourself as a required reviewer
