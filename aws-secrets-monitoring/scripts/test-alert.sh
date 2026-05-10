#!/usr/bin/env bash
# test-alert.sh
# Triggers the full monitoring pipeline by reading the secret via AWS CLI.
# CloudTrail will record GetSecretValue → metric filter → alarm → SNS email.
#
# Usage: ./test-alert.sh [SECRET_NAME] [REGION]

set -euo pipefail

SECRET_NAME="${1:-TopSecretInfo}"
REGION="${2:-us-east-1}"

echo "🔓 Retrieving secret '${SECRET_NAME}' in region '${REGION}'..."
aws secretsmanager get-secret-value \
  --secret-id "${SECRET_NAME}" \
  --region "${REGION}" \
  --query 'Name' \
  --output text

echo ""
echo "✅ Secret retrieved. CloudTrail should now record a GetSecretValue event."
echo "⏳ Allow 1–5 minutes for the metric filter to fire and for the SNS email to arrive."
echo "📧 Check your inbox for: ALARM: \"SecretIsAccessedAlarm\""
