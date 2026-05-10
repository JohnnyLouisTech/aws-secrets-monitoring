terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

# ---------------- Secrets Manager ----------------
resource "aws_secretsmanager_secret" "sensitive" {
  name        = var.secret_name
  description = "Simulated production credential used for monitoring testing."
}

resource "aws_secretsmanager_secret_version" "sensitive" {
  secret_id     = aws_secretsmanager_secret.sensitive.id
  secret_string = jsonencode({ username = "admin", password = "REPLACE_ME" })
}

# ---------------- S3 bucket for CloudTrail logs ----------------
resource "aws_s3_bucket" "trail" {
  bucket        = "${data.aws_caller_identity.current.account_id}-${var.trail_name}-logs"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "trail" {
  bucket                  = aws_s3_bucket.trail.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "trail" {
  bucket = aws_s3_bucket.trail.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "trail" {
  bucket = aws_s3_bucket.trail.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AWSCloudTrailAclCheck"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:GetBucketAcl"
        Resource  = aws_s3_bucket.trail.arn
      },
      {
        Sid       = "AWSCloudTrailWrite"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.trail.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# ---------------- CloudWatch Logs ----------------
resource "aws_cloudwatch_log_group" "trail" {
  name              = var.log_group_name
  retention_in_days = 30
}

resource "aws_iam_role" "trail_to_logs" {
  name = "${var.trail_name}-cwlogs-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "cloudtrail.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "trail_to_logs" {
  role = aws_iam_role.trail_to_logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Resource = "${aws_cloudwatch_log_group.trail.arn}:*"
    }]
  })
}

# ---------------- CloudTrail ----------------
resource "aws_cloudtrail" "trail" {
  name                          = var.trail_name
  s3_bucket_name                = aws_s3_bucket.trail.id
  include_global_service_events = true
  is_multi_region_trail         = false
  enable_log_file_validation    = true

  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.trail.arn}:*"
  cloud_watch_logs_role_arn  = aws_iam_role.trail_to_logs.arn

  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }

  depends_on = [aws_s3_bucket_policy.trail]
}

# ---------------- SNS Topic + Subscription ----------------
resource "aws_sns_topic" "security_alerts" {
  name         = "SecurityAlerts"
  display_name = "Security Alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.security_alerts.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

# ---------------- Metric Filter ----------------
resource "aws_cloudwatch_log_metric_filter" "secret_access" {
  name           = "SecretIsAccessedFilter"
  log_group_name = aws_cloudwatch_log_group.trail.name
  pattern        = "{ $.eventName = \"GetSecretValue\" }"

  metric_transformation {
    name          = "SecretIsAccessed"
    namespace     = "SecurityMetrics"
    value         = "1"
    default_value = "0"
  }
}

# ---------------- Alarm ----------------
resource "aws_cloudwatch_metric_alarm" "secret_access" {
  alarm_name          = var.alarm_name
  alarm_description   = "This alarm goes off whenever a secret in Secrets Manager is accessed (GetSecretValue)."
  namespace           = "SecurityMetrics"
  metric_name         = "SecretIsAccessed"
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.security_alerts.arn]
}
