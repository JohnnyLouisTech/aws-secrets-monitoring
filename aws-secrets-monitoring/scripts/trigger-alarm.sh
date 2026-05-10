#!/usr/bin/env bash
# trigger-alarm.sh
# Manually fires the CloudWatch alarm so you can confirm SNS email delivery
# without waiting for the metric filter to aggregate events.
#
# Usage: ./trigger-alarm.sh [ALARM_NAME] [REGION]

set -euo pipefail

ALARM_NAME="${1:-SecretIsAccessedAlarm}"
REGION="${2:-us-east-1}"

echo "🚨 Manually triggering alarm '${ALARM_NAME}' in '${REGION}'..."
aws cloudwatch set-alarm-state \
  --alarm-name "${ALARM_NAME}" \
  --state-value ALARM \
  --state-reason "Manually triggered for testing" \
  --region "${REGION}"

echo ""
echo "✅ Alarm state set to ALARM. Check your subscribed email inbox."
