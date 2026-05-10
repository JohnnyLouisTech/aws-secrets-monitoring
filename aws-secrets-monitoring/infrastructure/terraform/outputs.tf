output "secret_arn" {
  description = "ARN of the monitored secret."
  value       = aws_secretsmanager_secret.sensitive.arn
}

output "trail_arn" {
  description = "ARN of the CloudTrail trail."
  value       = aws_cloudtrail.trail.arn
}

output "log_group_name" {
  description = "CloudWatch Logs log group capturing CloudTrail events."
  value       = aws_cloudwatch_log_group.trail.name
}

output "sns_topic_arn" {
  description = "SNS topic ARN for security alerts."
  value       = aws_sns_topic.security_alerts.arn
}

output "alarm_name" {
  description = "CloudWatch alarm name."
  value       = aws_cloudwatch_metric_alarm.secret_access.alarm_name
}
