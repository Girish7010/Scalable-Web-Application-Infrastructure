#!/usr/bin/env bash
set -euo pipefail
LISTENER_ARN="${1:-}"; TG_BLUE="${2:-}"; TG_GREEN="${3:-}"; BLUE_W="${4:-80}"; GREEN_W="${5:-20}"
if [[ -z "$LISTENER_ARN" || -z "$TG_BLUE" || -z "$TG_GREEN" ]]; then echo "Missing args"; exit 1; fi
aws elbv2 modify-listener --listener-arn "$LISTENER_ARN" --default-actions Type=forward,ForwardConfig='{"TargetGroups":[{"TargetGroupArn":"'"$TG_BLUE"'","Weight":'"$BLUE_W"'},{"TargetGroupArn":"'"$TG_GREEN"'","Weight":'"$GREEN_W"'}]}'
