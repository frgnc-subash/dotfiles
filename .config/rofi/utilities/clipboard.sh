#!/usr/bin/env bash

NUM_ENTRIES=10

mapfile -t HISTORY < <(cliphist list | tac | tail -n "$NUM_ENTRIES")

MENU=()
MENU+=("󰅎 Clear Clipboard")
MENU+=("${HISTORY[@]}")

SELECTED=$(printf '%s\n' "${MENU[@]}" | rofi -dmenu -p " Clipboard :")

[ -z "$SELECTED" ] && exit

if [ "$SELECTED" = "󰅎 Clear Clipboard" ]; then
    cliphist wipe
    echo -n | wl-copy
    exit
fi

ID=$(echo "$SELECTED" | cut -d: -f1)
cliphist decode "$ID" | wl-copy
