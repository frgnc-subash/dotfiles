#!/bin/bash

count=$(swaync-client -c)
dnd=$(swaync-client -D)

if [ "$dnd" == "true" ]; then
    echo "󰂛"
else
    if [ -n "$count" ] && [ "$count" -gt 0 ]; then
        echo "󱅫"
    else
        echo "󰂚"
    fi
fi
