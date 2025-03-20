#!/bin/bash

: ${SLEEP_TIME:=5}
: ${REQUEST_IP:="0.0.0.0"}
: ${AUTORUN:="true"}

while [ "$AUTORUN" = "true" ]; do
    /behavior/behavior.sh
    sleep $SLEEP_TIME

    AUTORUN=$(printenv AUTORUN)
done