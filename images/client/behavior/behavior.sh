#!/bin/bash

LOG_FILE="/behavior/requests.log"

TIMESTAMP="[$(date '+%Y-%m-%d %H:%M:%S')]"

START_TIME=$(date +%s%N)

RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" "$REQUEST_TARGET")

HTTP_STATUS=$(echo "$RESPONSE" | grep -oP '(?<=HTTP_STATUS:)[0-9]+')
BODY=$(echo "$RESPONSE" | sed 's/HTTP_STATUS:[0-9]*//')

END_TIME=$(date +%s%N)
EXECUTION_TIME=$(( (END_TIME - START_TIME) / 1000000 ))

echo "$TIMESTAMP - Executing request to $REQUEST_TARGET" | tee -a "$LOG_FILE"
echo "HTTP Code: $HTTP_STATUS" | tee -a "$LOG_FILE"
echo "Execution time: ${EXECUTION_TIME}ms" | tee -a "$LOG_FILE"
echo "Response:" | tee -a "$LOG_FILE"
echo "$BODY" | tee -a "$LOG_FILE"
echo "------------------------------------------------------------------------------" | tee -a "$LOG_FILE"
