# Real-Time Sensitive Secrets Monitoring and Alerting in AWS

> Unauthorized Secret Access Detection — a cloud security monitoring pipeline built on AWS Secrets Manager, CloudTrail, CloudWatch, and SNS.

[![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?logo=amazon-aws&logoColor=white)](https://aws.amazon.com/)
[![CloudFormation](https://img.shields.io/badge/IaC-CloudFormation-blue)](https://aws.amazon.com/cloudformation/)
[![Terraform](https://img.shields.io/badge/IaC-Terraform-7B42BC?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

📖 **Full writeup on Medium:** [Real-Time Sensitive Secrets Monitoring and Alerting in AWS](https://medium.com/@jlouis26/real-time-sensitive-secrets-monitoring-and-alerting-in-aws-b99713718cda)

![Architecture](docs/images/architecture.svg)

---

## 📋 Project Scenario

A financial services company stores sensitive database credentials and API keys in AWS Secrets Manager. To improve security monitoring, this project implements a real-time alerting solution using **CloudTrail**, **CloudWatch**, and **SNS** to detect whenever sensitive secrets are accessed.

During testing, a secret is retrieved through both the AWS Console and AWS CLI, which triggers CloudTrail logs, CloudWatch alarms, and SNS email alerts — simulating a cloud security incident detection workflow. This gives a security team rapid visibility into suspicious access attempts and improves response times for potential credential compromise events.

## 🎯 Objectives

- Monitor sensitive secret access activity in real time
- Detect suspicious retrieval of secrets
- Generate cloud security alerts via email
- Improve audit visibility into Secrets Manager API calls
- Simulate SOC monitoring workflows
- Strengthen AWS security operations skills

## 🧰 AWS Services Used

| Service                    | Purpose                                      |
|----------------------------|----------------------------------------------|
| AWS Secrets Manager        | Stores the sensitive secret (`TopSecretInfo`) |
| AWS CloudTrail             | Captures all Secrets Manager API activity    |
| Amazon CloudWatch Logs     | Ingests CloudTrail events for analysis       |
| CloudWatch Metric Filter   | Extracts `GetSecretValue` events             |
| CloudWatch Alarms          | Triggers when secrets are accessed           |
| Amazon SNS                 | Delivers email alerts to subscribers         |
| Amazon S3                  | Stores raw CloudTrail logs                   |
| AWS CLI / CloudShell       | Test access and manually fire alarms         |

## 🚀 Quick Start

You can deploy the full stack with either CloudFormation or Terraform.

### Option 1 — CloudFormation

```bash
aws cloudformation deploy \
  --template-file infrastructure/cloudformation/secrets-monitoring.yaml \
  --stack-name secrets-monitoring \
  --parameter-overrides \
      NotificationEmail=you@example.com \
      SecretName=TopSecretInfo \
  --capabilities CAPABILITY_NAMED_IAM \
  --region us-east-1
```

Confirm the SNS subscription email that lands in your inbox, then run the test script:

```bash
./scripts/test-alert.sh TopSecretInfo us-east-1
```

### Option 2 — Terraform

```bash
cd infrastructure/terraform
terraform init
terraform apply \
  -var="notification_email=you@example.com" \
  -var="secret_name=TopSecretInfo" \
  -var="aws_region=us-east-1"
```

---

## 📐 Step-by-Step Walkthrough (Console)

### Step 1 — Create the Sensitive Secret

Open **Secrets Manager** and create a new secret of type "Other type of secret" named `TopSecretInfo`.

![Open Secrets Manager](docs/images/01-secrets-manager-open.png)
![Create new secret](docs/images/02-create-secret.png)
![Secret name](docs/images/03-secret-name.png)
![Key and description](docs/images/04-secret-key-description.png)
![Secret created](docs/images/05-secret-created.png)

> *TopSecretInfo was successfully created.* This simulates sensitive credentials used in production cloud environments.

---

### Step 2 — Configure CloudTrail Logging

Create a trail (`nextwork-secrets-manager-trail-jl`) that captures management events.

> ⚠️ **Uncheck "Log file SSE-KMS encryption"** — otherwise AWS will charge you for a customer-managed KMS key.

![CloudTrail console](docs/images/06-cloudtrail-open.png)
![Create trail](docs/images/07-create-trail.png)
![Trail name](docs/images/08-trail-name.png)
![Uncheck KMS encryption](docs/images/09-uncheck-kms.png)
![Management events](docs/images/10-management-events.png)
![Read + Write checked](docs/images/11-read-write-checked.png)
![CloudTrail setup review](docs/images/12-cloudtrail-setup-review.png)
![Trail log location](docs/images/13-trail-log-location.png)
![Exclude KMS events](docs/images/14-exclude-kms-events.png)

---

### Step 3 — Generate Secret Access Events

Retrieve the secret via Console **and** via the AWS CLI in CloudShell:

```bash
aws secretsmanager get-secret-value --secret-id "TopSecretInfo" --region us-east-1
```

![Retrieve via Console](docs/images/15-retrieve-via-console.png)
![Pick TopSecretInfo](docs/images/16-pick-topsecretinfo.png)
![Secret value shown](docs/images/17-secret-value-shown.png)
![CloudShell CLI](docs/images/18-cloudshell-cli.png)
![CLI result JSON](docs/images/19-cli-result-json.png)

---

### Step 4 — Investigate CloudTrail Events

Filter Event History by event source `secretsmanager.amazonaws.com` and locate the `GetSecretValue` rows.

![CloudTrail console again](docs/images/20-cloudtrail-console-again.png)
![Event History](docs/images/21-event-history.png)
![Lookup → Event source](docs/images/22-lookup-event-source.png)
![Search source](docs/images/23-search-secretsmanager-source.png)
![GetSecretValue events](docs/images/24-getsecretvalue-events.png)

---

### Step 5 — Send Logs to CloudWatch

Enable CloudWatch Logs integration on the trail and verify events arrive in `nextwork-secretsmanager-loggroup`.

![Trail detail](docs/images/25-cloudtrail-trail-detail.png)
![Enable CWLogs](docs/images/26-enable-cwlogs.png)
![Log group name](docs/images/27-loggroup-name.png)
![Verify CWLogs](docs/images/28-verify-cwlogs.png)
![Log stream](docs/images/29-log-stream-pick.png)
![Logs inside stream](docs/images/30-logs-inside-stream.png)
![Expanded log](docs/images/31-expanded-log.png)

---

### Step 6 — Create the CloudWatch Metric Filter

Pattern: `GetSecretValue`. Namespace: `SecurityMetrics`. Metric name: `SecretIsAccessed`. Value: `1`.

![Create metric filter](docs/images/32-metric-filter-create.png)
![Filter pattern](docs/images/33-filter-pattern.png)
![Test pattern](docs/images/34-test-pattern.png)
![Metric config](docs/images/35-metric-config.png)
![Metric filter created](docs/images/36-metric-filter-created.png)

---

### Step 7 — Create the CloudWatch Alarm

Statistic: `Sum`. Period: `5 minutes`. Threshold: `≥ 1`.

![Alarm metric select](docs/images/37-alarm-metric-select.png)
![Statistic + period](docs/images/38-alarm-statistic-period.png)
![Threshold](docs/images/39-alarm-threshold.png)
![Notification settings](docs/images/40-alarm-notification.png)

---

### Step 8 — Configure SNS Notifications

Create SNS topic `Security Alerts` and subscribe your email. Confirm the subscription from the email link.

![Create SNS topic](docs/images/41-sns-topic-create.png)
![Alarm description](docs/images/42-alarm-description.png)
![Alarm conditions](docs/images/43-alarm-conditions.png)
![Alarm created banner](docs/images/44-alarm-created-banner.png)
![Subscribe email](docs/images/45-email-subscribe.png)
![Subscription confirmed](docs/images/46-subscription-confirmed.png)

---

### Step 9 — Trigger the Security Incident

Retrieve the secret again to validate the full pipeline.

![Trigger event](docs/images/47-trigger-event.png)
![Secret exposed again](docs/images/48-secret-exposed-again.png)

---

### Step 10 — Investigate the Alert

Confirm CloudTrail captured the event, the metric filter matched, the alarm fired, and the email landed.

![Event history check](docs/images/49-event-history-check.png)
![GetSecretValue row](docs/images/50-getsecretvalue-row.png)
![Test pattern match](docs/images/51-test-pattern-match.png)
![CloudShell help](docs/images/52-cloudshell-help.png)
![Help scrolled](docs/images/53-help-scrolled.png)
![Set-alarm-state run](docs/images/54-set-alarm-state-run.png)
![Email from manual trigger](docs/images/55-email-manual-trigger.png)
![SNS console](docs/images/56-sns-console.png)
![Security Alerts topic](docs/images/57-security-alerts-topic.png)
![Publish message](docs/images/58-publish-message.png)
![Message subject + body](docs/images/59-message-subject-body.png)
![Publish confirmation](docs/images/60-publish-confirmation.png)
![SNS email received](docs/images/61-sns-email-received.png)
![Alarm refreshed](docs/images/62-alarm-refreshed.png)
![Final alarm email](docs/images/63-final-alarm-email.png)

---

## 🧪 Testing the Alarm

Trigger the alarm manually without waiting for metric aggregation:

```bash
aws cloudwatch set-alarm-state \
  --alarm-name "SecretIsAccessedAlarm" \
  --state-value ALARM \
  --state-reason "Manually triggered for testing"
```

Or trigger the full pipeline by reading the secret:

```bash
aws secretsmanager get-secret-value \
  --secret-id TopSecretInfo \
  --region us-east-1
```

You should receive an email titled **ALARM: "SecretIsAccessedAlarm"** within a few minutes.

## 🗂️ Repository Layout

```
.
├── README.md
├── LICENSE
├── .gitignore
├── docs/
│   ├── architecture.md
│   ├── runbook.md
│   └── images/
│       ├── README.md                  ← filename map for screenshots
│       ├── architecture.svg           ← generated diagram
│       └── 01-…63-…png                ← drop your screenshots here
├── infrastructure/
│   ├── cloudformation/
│   │   └── secrets-monitoring.yaml
│   └── terraform/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── scripts/
    ├── test-alert.sh
    └── trigger-alarm.sh
```

## 🧹 Cleanup

To avoid ongoing charges (CloudTrail S3 storage, CloudWatch Logs ingest):

```bash
# CloudFormation
aws cloudformation delete-stack --stack-name secrets-monitoring

# Terraform
cd infrastructure/terraform && terraform destroy
```

## 📝 License

MIT — see [LICENSE](LICENSE).

## 👤 Author

**Johnny Louis** — Cloud Engineer passionate about DevOps & Security.

- Medium: [@jlouis26](https://medium.com/@jlouis26)
- GitHub: [@JohnnyLouisTech](https://github.com/JohnnyLouisTech)
