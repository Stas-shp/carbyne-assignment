variable "aws_region" {
    type = string
    default = "eu-west-1"
}

variable "vpc_name" {
    type = string
    default = "carbyne-vpc"
}

variable "sqs_name" {
    type = string
    default = "sqs-consumer"
}