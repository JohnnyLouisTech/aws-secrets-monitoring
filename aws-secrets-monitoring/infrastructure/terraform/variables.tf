variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "notification_email" {
  description = "Email address to receive SNS security alerts."
  type        = string
}

variable "secret_name" {
  description = "Name of the secret in Secrets Manager."
  type        = string
  default     = "TopSecretInfo"
}

variable "trail_name" {
  description = "Name of the CloudTrail trail."
  type        = string
  default     = "nextwork-secrets-manager-trail"
}

variable "log_group_name" {
  description = "CloudWatch Logs log group name."
  type        = string
  default     = "nextwork-secretsmanager-loggroup"
}

variable "alarm_name" {
  description = "Name of the CloudWatch alarm."
  type        = string
  default     = "SecretIsAccessedAlarm"
}
