#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

declare -r ICON=""

# Matches your requested style
declare -ra ROFI_CMD=(
    rofi
    -dmenu
    -i
    -markup-rows
    -theme-str '@import "~/.config/matugen/generated/rofi-colors.rasi"'
    -theme-str 'window {width: 400px;}'
    -theme-str 'listview {lines: 3;}'
    -mesg "<span size='x-small'>Type equation. <b>Enter</b> to calc/copy. <b>Esc</b> to exit.</span>"
)

check_dependencies() {
    local -a missing=()
    local cmd
    for cmd in rofi bc wl-copy; do
        command -v "$cmd" &>/dev/null || missing+=("$cmd")
    done
    
    if ((${#missing[@]} > 0)); then
        printf 'Error: Missing dependencies: %s\n' "${missing[*]}" >&2
        exit 1
    fi
}

calc_engine() {
    local input="$1"
    # Use bc with math library, strip trailing zeros
    local result
    if result=$(echo "scale=4; $input" | bc -l 2>/dev/null); then
        # Remove trailing zeros and decimal point if not needed
        echo "$result" | sed 's/\.0*$//;s/\.\([0-9]*[1-9]\)0*$/.\1/'
    else
        echo "Error"
    fi
}

main() {
    check_dependencies
    
    local input=""
    local result=""
    local history=""
    local display_list=""
    local exit_code
    
    while true; do
        # Build the list to show in Rofi
        if [[ -n "$result" && "$result" != "Error" ]]; then
            display_list="${ICON}  = <b>${result}</b>"
        else
            display_list=""
        fi
        
        # Run Rofi
        # We use -filter to keep the last equation typed if we are looping
        if ! input=$(echo -e "$display_list" | "${ROFI_CMD[@]}" -p "$ICON" -filter "$history"); then
            exit 0 # User pressed Esc
        fi

        # Logic: 
        # 1. If input matches the displayed result line, user selected it -> Copy
        # 2. If input is just a number/result, user hit enter on filter -> Copy
        # 3. Otherwise, it is a new equation -> Calculate
        
        # Clean input (remove icon if selected from list)
        local clean_input="${input#*${ICON}  = <b>}"
        clean_input="${clean_input%</b>}"

        if [[ "$clean_input" == "$result" && -n "$result" ]]; then
            # Copy to clipboard
            printf '%s' "$result" | wl-copy
            if command -v notify-send &>/dev/null; then
                notify-send -i accessories-calculator "Calculator" "Copied: $result"
            fi
            exit 0
        fi
        
        # Perform Calculation
        if [[ -n "$input" ]]; then
            result=$(calc_engine "$input")
            
            # If calculation was successful, update history to show empty box next time
            # so user can see the result in the list but type a new one
            if [[ "$result" != "Error" ]]; then
                history="" 
            else
                # If error, keep the input so user can fix it
                history="$input"
                result="Error"
            fi
        fi
    done
}

main "$@"