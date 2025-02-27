#!/bin/bash

if [ "$AUTO_RUN" = "true" ]; then
    /usr/local/bin/behavior.sh &
fi

tail -f /dev/null
