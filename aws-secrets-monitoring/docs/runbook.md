# Incident Response Runbook — Secret Access Alert

> Use this runbook when the `SecretIsAccessedAlarm` fires and an `ALARM: "SecretIsAccessedAlarm"` email lands in the security inbox.

## Triage (first 5 minutes)

1. **Open CloudTrail Event History** in the affected account/region.
2. **Filter by event source** `secretsmanager.amazonaws.com` and event name `GetSecretValue`.
3. Identify the most recent event and capture:
   - `eventTime`
   - `userIdentity.arn` (who)
   - `sourceIPAddress` (where from)
   - `userAgent` (Console? CLI? SDK?)
   - `requestParameters.secretId` (which secret)
   - `sessionCredentialFromConsole` (was this a Console session?)

## Classification

| Indicator                                              | Likely benign        | Likely suspicious                              |
|--------------------------------------------------------|----------------------|------------------------------------------------|
| `userIdentity.type`                                    | `AssumedRole` from a known service role | `IAMUser` outside the deploy/CI accounts       |
| `sourceIPAddress`                                      | Known corporate or VPC NAT IP            | Foreign IP, residential ISP, Tor exit node     |
| `userAgent`                                            | `aws-sdk-*` from a known service         | `curl`, generic Python, or unrecognized agent  |
| Time of day                                            | Business hours       | Off-hours / weekends                           |
| `mfaAuthenticated`                                     | `true` for human users                   | `false` for human users                        |

## Response

### If suspicious

1. **Rotate the secret immediately:**
   ```bash
   aws secretsmanager rotate-secret --secret-id <SECRET_ARN>
   ```
2. **Suspend the principal:** detach all policies from the IAM user/role or apply an explicit `Deny *`.
3. **Search for lateral movement:** in CloudTrail, filter by the same `accessKeyId` to see what else the principal did in the last 24 hours.
4. **Notify the on-call engineering lead** and open an incident ticket.
5. **Preserve evidence:** export the relevant CloudTrail events and CloudWatch Logs to an evidence S3 prefix.

### If benign

1. Document the legitimate caller and reason in the alert ticket.
2. Consider adding the principal to an allow-list (see "Reducing noise" below).
3. Close the alert.

## Reducing noise

If the alarm is too chatty, tighten the metric filter pattern. Examples:

Only alarm on human (Console) access:
```
{ ($.eventName = "GetSecretValue") && ($.sessionCredentialFromConsole = "true") }
```

Exclude a known service role:
```
{ ($.eventName = "GetSecretValue") && ($.userIdentity.arn != "arn:aws:sts::*:assumed-role/MyAppRole/*") }
```

Only alarm on failed attempts (often a stronger signal):
```
{ ($.eventName = "GetSecretValue") && ($.errorCode = "*") }
```

## References

- [CloudTrail event reference for Secrets Manager](https://docs.aws.amazon.com/secretsmanager/latest/userguide/logging-using-cloudtrail.html)
- [CloudWatch Logs metric filter syntax](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/FilterAndPatternSyntax.html)
