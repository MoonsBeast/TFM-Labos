#!/bin/bash

while true; do
    #RESPONSE=$(curl -s -X GET $TARGET_IP)
    #echo "Respuesta del servidor: $RESPONSE"
    curl -s -X GET $TARGET_IP
    sleep $TIME_LAPSE
done
