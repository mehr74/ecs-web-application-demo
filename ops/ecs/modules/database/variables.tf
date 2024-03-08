variable "image" {
  type        = string
  description = "The image to be used for the container."
  default     = "615677714887.dkr.ecr.eu-central-1.amazonaws.com/ecs-web-application-demo-db-repo"
}

variable "ecr_arn" {
  type        = string
  description = "The ARN of the ECR repository."
  default     = "arn:aws:ecr:eu-central-1:615677714887:repository/ecs-web-application-demo-db-repo"
}

variable "cluster_id" {
  type        = string
  description = "The ID of the cluster to which the container blongs."
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC to which the container should be deployed."
}

variable "vpc_public_subnets" {
  type        = list(string)
  description = "The public subnets to which the container should be deployed."
}

variable "security_group_id" {
  type        = string
  description = "The security group to which the container should be attached."
}

variable "namespace_id" {
  type        = string
  description = "The ID of the namespace to which the container should be attached."
}

variable "secret_manager_name" {
  type        = string
  description = "The name of the secret manager."
}