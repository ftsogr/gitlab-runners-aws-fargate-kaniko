#!/bin/bash

# Configurations
THRESHOLD_SECONDS=14400               # Threshold in seconds for long-running tasks
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/XXXXXXX"  # Replace with your webhook URL
TIMEZONE="GMT-2" # Timezone for task timing adjustments 

# Get the current timestamp in seconds since epoch
now=$(TZ=$TIMEZONE date +%s%3N)
# Fetch all ECS clusters
CLUSTERS=$(aws ecs list-clusters --query "clusterArns[]" --output text)

if [ -z "$CLUSTERS" ]; then
  echo "No ECS clusters found."
  exit 0
fi

# Loop through each cluster
for CLUSTER in $CLUSTERS; do
  echo "Processing cluster: $CLUSTER"

  # Fetch running ECS tasks for the current cluster
  TASK_ARNS=$(aws ecs list-tasks --cluster "$CLUSTER" --desired-status RUNNING --query "taskArns[]" --output text)

  if [ -z "$TASK_ARNS" ]; then
    echo "No running tasks in cluster $CLUSTER."
    continue
  fi

  # Describe tasks
  TASK_DETAILS=$(aws ecs describe-tasks --cluster "$CLUSTER" --tasks $TASK_ARNS --output json)

  # Parse tasks and identify long-running ones
  LONG_RUNNING_TASKS=()
  while IFS= read -r task; do
    TASK_ARN=$(echo "$task" | jq -r '.taskArn')
    LAST_STATUS=$(echo "$task" | jq -r '.lastStatus')

    # Skip tasks that are not in the RUNNING state
    if [ "$LAST_STATUS" != "RUNNING" ]; then
      echo "Skipping task $TASK_ARN as it is in status: $LAST_STATUS"
      continue
    fi
    # Extract startedAt timestamp (in milliseconds)
    started_at_str=$(echo "$task" | jq -r '.startedAt')
    # Skip tasks without a valid startedAt timestamp
    if [ -z "$started_at_str" ] || [ "$started_at_str" == "null" ]; then
      echo "Skipping task $TASK_ARN as it does not have a valid startedAt timestamp."
      continue
    fi

    started_at=$(TZ=$TIMEZONE date -d "$started_at_str" +%s%3N)
    # Calculate runtime in seconds
    running_time_seconds=$(( (now - started_at) / 1000 ))
    # Check if runtime exceeds threshold
    if [ "$running_time_seconds" -ge "$THRESHOLD_SECONDS" ]; then
      # Convert start time to human-readable format
      # Perform division to remove last 3 digits (milliseconds -> seconds)
      started_at_seconds=$((started_at / 1000))

      # Convert the Unix timestamp (in seconds) to local time
      started_at_local=$(TZ=$TIMEZONE date -d @$started_at_seconds)
      # Convert runtime secs of tasks to hours
      runtime_in_hours=$((running_time_seconds / 3600))
      LONG_RUNNING_TASKS+=("$TASK_ARN|$started_at_local|$runtime_in_hours hours")
    fi
  done <<< "$(echo "$TASK_DETAILS" | jq -c '.tasks[]')"
  # Notify Slack if long-running tasks exist
  if [ ${#LONG_RUNNING_TASKS[@]} -eq 0 ]; then
    echo "No long-running tasks in cluster $CLUSTER."
    continue
  fi

  # Construct Slack message
  SLACK_MESSAGE="*⚠️ Long-running ECS tasks detected in cluster \`$CLUSTER\`:*\n"
  for TASK_INFO in "${LONG_RUNNING_TASKS[@]}"; do
    IFS='|' read -r TASK_ARN STARTED_AT_LOCAL RUNTIME <<< "$TASK_INFO"
    SLACK_MESSAGE+="• *Task ARN:* \`$TASK_ARN\`\n  *Started At:* $STARTED_AT_LOCAL\n  *Runtime:* $RUNTIME\n"
  done

  # Send message to Slack
  curl -X POST -H 'Content-type: application/json' \
    --data '{"channel": "#prometheus-alerts", "text": "'"$SLACK_MESSAGE"'"}' \
    "$SLACK_WEBHOOK_URL"

  echo "Notification sent to Slack for cluster $CLUSTER."
done

