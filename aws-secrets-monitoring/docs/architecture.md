# Architecture

## Overview

This project implements a closed-loop detection pipeline for sensitive secret access events in AWS. Every time a principal calls `GetSecretValue` on the monitored secret, the event traverses CloudTrail → CloudWatch Logs → a metric filter → a CloudWatch alarm → an SNS topic, and finally lands as an email in a security responder's inbox.

## Data flow

1. **Event source — Secrets Manager.** A user, application, or service principal calls `GetSecretValue` (or any other Secrets Manager API).
2. **Audit capture — CloudTrail.** A management-event trail captures all read and write API calls and writes them to an S3 bucket and a CloudWatch Logs log group.
3. **Real-time ingest — CloudWatch Logs.** CloudTrail streams events into the `nextwork-secretsmanager-loggroup` log group via an IAM role.
4. **Detection — Metric Filter.** A JSON metric filter pattern `{ $.eventName = "GetSecretValue" }` increments the `SecurityMetrics/SecretIsAccessed` custom metric by 1 for each matching event.
5. **Threshold — CloudWatch Alarm.** The alarm fires when `Sum(SecretIsAccessed) >= 1` over a 5-minute period.
6. **Notification — SNS.** The alarm action publishes to the `SecurityAlerts` SNS topic, which fans out to email subscribers.

## Why this works for SOC-style monitoring

- **Latency:** Events typically land in CloudWatch Logs within 1–5 minutes of the API call. The 5-minute alarm period balances responsiveness against false positives.
- **Auditability:** Raw CloudTrail logs persist in S3 for forensic replay; CloudWatch Logs give real-time grep-ability.
- **Extensibility:** The metric filter pattern can be tightened (e.g., filter by `userIdentity.type = "IAMUser"`, exclude allow-listed principals, or alarm only when `sourceIPAddress` is outside corporate ranges).
- **Cost:** The pipeline is essentially free at low volume — CloudTrail management events are free for the first copy, CloudWatch Logs ingest is cheap, and SNS email is free for the first 1,000 notifications/month.

## Hardening considerations for production

- **Multi-region trail.** Set `IsMultiRegionTrail: true` and `IncludeGlobalServiceEvents: true` to capture events in every region.
- **Log file integrity.** Enable `EnableLogFileValidation: true` (already set) to detect tampering.
- **KMS encryption.** The original tutorial intentionally skips SSE-KMS to avoid charges, but production deployments should encrypt both the S3 bucket and CloudWatch Logs with a customer-managed KMS key.
- **Tighter filter.** Add filters for `errorCode` to detect failed access attempts (often a stronger signal than successful reads by legitimate principals).
- **Anomaly detection.** Use CloudWatch Anomaly Detection instead of a static threshold once you have a baseline of expected access volume.
- **Cross-account aggregation.** In multi-account orgs, forward events to a central security account via Organization Trails and centralized CloudWatch Logs subscriptions.
- **Response automation.** Subscribe a Lambda function to the SNS topic to enrich alerts (look up the IAM principal, query GuardDuty, post to Slack/PagerDuty) instead of relying on email alone.
