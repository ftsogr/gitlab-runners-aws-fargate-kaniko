# AWS-related variables
variable "fargate_cluster" {
  description = "Name of the Fargate cluster"
  type        = string
}

variable "fargate_region" {
  description = "The AWS region to deploy Fargate resources"
  type        = string
}

variable "fargate_subnet         = "subnet-xxxxxxxx"
  description = "Subnet ID for the Fargate task"
  type        = string
}

variable "fargate_security_group = "sg-xxxxxxxx"
  description = "Security group ID for the Fargate task"
  type        = string
}

variable "project" {
  description = "GitLab project"
  type        = string
}

variable "ecsTaskExecutionRoleArn" {
  description = "IAM role ARN for ECS task execution"
  type        = string
}


variable "java_fargate_task_definition" {
  description = "Task definition for Fargate to build java projects"
  type        = string
}

variable "java_runner_image" {
  description = "Docker image to use for the java runner"
  type        = string
}

variable "java_fargate_cpu" {
  description = "CPU units for the Fargate java task"
  type        = string
}

variable "java_fargate_memory" {
  description = "Memory (in MiB) for the Fargate java task"
  type        = string
}