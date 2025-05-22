#!/bin/sh

: "${TARGET_URL:=http://127.0.0.1:8080}"

echo "[*] Haciendo peticiones HTTP a: $TARGET_URL"
while true; do

    TIMESTAMP="[$(date '+%Y-%m-%d %H:%M:%S')]"

    echo "$TIMESTAMP - Iniciando petición GET a $REQUEST_TARGET"

    # Crear archivos temporales para la respuesta y las métricas
    RESPONSE_FILE=$(mktemp)
    METRICS_FILE=$(mktemp)

    # Realizar la petición y guardar la respuesta y métricas por separado
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

    echo "$TIMESTAMP - Estadísticas de la petición:"
    cat "$METRICS_FILE" | jq .

    echo "Response body:"
    cat "$RESPONSE_FILE" | jq . 2>/dev/null || cat "$RESPONSE_FILE"

    echo "------------------------------------------------------------------------------"

    # Limpiar archivos temporales
    rm -f "$RESPONSE_FILE" "$METRICS_FILE"

    # Si queremos que el script espere antes de la siguiente petición
    if [ ! -z "$SLEEP_TIME" ]; then
        sleep "$SLEEP_TIME"
    fi
done
