#!/bin/bash
count=$(swaync-client -c)
if [ -z "$count" ] || [ "$count" -eq 0 ]; then
  echo "󰂚"   
else
  echo "󰂚 $count"
fi
