# Screenshots

Drop your Medium article screenshots here using the filenames below. The main `README.md` already references each one — once the files are in place, GitHub will render the images automatically.

## Filename map

| Filename                                  | Shows                                                  |
|-------------------------------------------|--------------------------------------------------------|
| `01-secrets-manager-open.png`             | Secrets Manager console landing                        |
| `02-create-secret.png`                    | "Create a new secret" button                           |
| `03-secret-name.png`                      | Entering name `TopSecretInfo`                          |
| `04-secret-key-description.png`           | Key and description fields                             |
| `05-secret-created.png`                   | Success — `TopSecretInfo` listed                       |
| `06-cloudtrail-open.png`                  | CloudTrail console                                     |
| `07-create-trail.png`                     | Create trail form                                      |
| `08-trail-name.png`                       | Trail name `nextwork-secrets-manager-trail-jl`         |
| `09-uncheck-kms.png`                      | Unchecking SSE-KMS encryption                          |
| `10-management-events.png`                | Enabling management events                             |
| `11-read-write-checked.png`               | Read + Write checkboxes                                |
| `12-cloudtrail-setup-review.png`          | Final CloudTrail setup review                          |
| `13-trail-log-location.png`               | Trail log location (S3 path)                           |
| `14-exclude-kms-events.png`               | Exclude AWS KMS events                                 |
| `15-retrieve-via-console.png`             | Retrieving secret via Console                          |
| `16-pick-topsecretinfo.png`               | Picking `TopSecretInfo`                                |
| `17-secret-value-shown.png`               | Secret value displayed                                 |
| `18-cloudshell-cli.png`                   | CLI command in CloudShell                              |
| `19-cli-result-json.png`                  | JSON output of `get-secret-value`                      |
| `20-cloudtrail-console-again.png`         | Back to CloudTrail console                             |
| `21-event-history.png`                    | Event History tab                                      |
| `22-lookup-event-source.png`              | Lookup attributes → Event source                       |
| `23-search-secretsmanager-source.png`     | Searching `secretsmanager.amazonaws.com`               |
| `24-getsecretvalue-events.png`            | Locating `GetSecretValue` events                       |
| `25-cloudtrail-trail-detail.png`          | Trail detail view                                      |
| `26-enable-cwlogs.png`                    | Enabling CloudWatch Logs integration                   |
| `27-loggroup-name.png`                    | Log group name `nextwork-secretsmanager-loggroup`      |
| `28-verify-cwlogs.png`                    | Verifying logs in CloudWatch                           |
| `29-log-stream-pick.png`                  | Selecting a log stream                                 |
| `30-logs-inside-stream.png`               | Heaps of logs inside the stream                        |
| `31-expanded-log.png`                     | Expanded log event                                     |
| `32-metric-filter-create.png`             | Creating the metric filter                             |
| `33-filter-pattern.png`                   | Filter pattern `GetSecretValue`                        |
| `34-test-pattern.png`                     | Test pattern result                                    |
| `35-metric-config.png`                    | Namespace/name/value config                            |
| `36-metric-filter-created.png`            | Metric filter created                                  |
| `37-alarm-metric-select.png`              | Selecting the metric for the alarm                     |
| `38-alarm-statistic-period.png`           | Statistic = Sum, period = 5 min                        |
| `39-alarm-threshold.png`                  | Threshold ≥ 1                                          |
| `40-alarm-notification.png`               | Notification settings                                  |
| `41-sns-topic-create.png`                 | Creating SNS topic `Security Alerts`                   |
| `42-alarm-description.png`                | Alarm description                                      |
| `43-alarm-conditions.png`                 | Review conditions                                      |
| `44-alarm-created-banner.png`             | Green "alarm created" banner                           |
| `45-email-subscribe.png`                  | Subscribe email address                                |
| `46-subscription-confirmed.png`           | Subscription confirmed                                 |
| `47-trigger-event.png`                    | Triggering the alarm by re-reading secret              |
| `48-secret-exposed-again.png`             | Secret exposed again                                   |
| `49-event-history-check.png`              | Event History after re-trigger                         |
| `50-getsecretvalue-row.png`               | Top `GetSecretValue` row in Event History              |
| `51-test-pattern-match.png`               | Metric filter test pattern match                       |
| `52-cloudshell-help.png`                  | `aws cloudwatch set-alarm-state help`                  |
| `53-help-scrolled.png`                    | Help command scrolled                                  |
| `54-set-alarm-state-run.png`              | Running `set-alarm-state` manually                     |
| `55-email-manual-trigger.png`             | Email from manual trigger                              |
| `56-sns-console.png`                      | SNS console                                            |
| `57-security-alerts-topic.png`            | Selecting `Security Alerts` topic                      |
| `58-publish-message.png`                  | Publish message form                                   |
| `59-message-subject-body.png`             | Subject + body                                         |
| `60-publish-confirmation.png`             | Publish confirmation banner                            |
| `61-sns-email-received.png`               | SNS email in inbox                                     |
| `62-alarm-refreshed.png`                  | Refreshed alarm in CloudWatch                          |
| `63-final-alarm-email.png`                | Final `ALARM: "SecretIsAccessedAlarm"` email           |

## How to grab them from your Medium article

The quickest way:

1. Open the article in your browser.
2. Right-click each image → **Save image as...** → save into this folder using the filename above.
3. `git add docs/images/ && git commit -m "Add screenshots" && git push`

Alternatively, if you still have your original screenshot folder from when you wrote the article, just batch-rename them to match.
