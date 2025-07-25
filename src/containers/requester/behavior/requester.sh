#!/bin/sh

: "${TARGET_URL:=http://127.0.0.1:8080}"

echo "[*] Making HTTP requests to: $TARGET_URL"
while true; do

    TIMESTAMP="[$(date '+%Y-%m-%d %H:%M:%S')]"

    echo "$TIMESTAMP - Starting GET request to $REQUEST_TARGET"

    # Create temporary files for response and metrics
    RESPONSE_FILE=$(mktemp)
    METRICS_FILE=$(mktemp)

    # Make the request and save response and metrics separately
    curl -s "$REQUEST_TARGET" \
        -H "Accept: application/json" \
        -H "User-Agent: Custom-Client/1.0" \
        -o "$RESPONSE_FILE" \
        -w '{
        "time_total": "%{time_total}",
        "time_connect": "%{time_connect}",
        "time_appconnect": "%{time_appconnect}",
        "time_starttransfer": "%{time_starttransfer}",
        "size_download": "%{size_download}",
        "speed_download": "%{speed_download}",
        "http_code": "%{http_code}",
        "remote_ip": "%{remote_ip}",
        "remote_port": "%{remote_port}",
        "num_redirects": "%{num_redirects}",
        "url_effective": "%{url_effective}"
    }' > "$METRICS_FILE"

    echo "$TIMESTAMP - Request statistics:"
    cat "$METRICS_FILE" | jq .

    echo "Response body:"
    cat "$RESPONSE_FILE" | jq . 2>/dev/null || cat "$RESPONSE_FILE"

    echo "------------------------------------------------------------------------------"

    # Clean up temporary files
    rm -f "$RESPONSE_FILE" "$METRICS_FILE"

    # If we want the script to wait before the next request
    if [ ! -z "$SLEEP_TIME" ]; then
        sleep "$SLEEP_TIME"
    fi
done
