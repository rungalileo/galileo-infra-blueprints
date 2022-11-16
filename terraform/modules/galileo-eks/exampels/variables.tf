variable "vpc_id" {
  type        = string
  description = "ID of the VPC where the cluster and its nodes will be provisioned"
}

variable "private_subnet_id" {
  type        = list(string)
  description = "A list of subnet IDs where the nodes/node groups will be provisioned"
}
