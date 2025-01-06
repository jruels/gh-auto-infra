variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "project_tags" {
  description = "Tags for the project"
  type        = map(string)
  default = {
    Project = "github-actions-lab"
    Environment = "dev"
  }
} 
