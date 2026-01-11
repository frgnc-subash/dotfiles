#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

declare -rA ICONS=(
    [active]=""
    [inactive]=" "
    [off]=""
    [shader]=""
)

declare -ra ROFI_CMD=(
    rofi
    -dmenu
    -i
    -markup-rows
    -theme-str '@import "~/.config/matugen/generated/rofi-colors.rasi"'
    -theme-str 'window {width: 400px;}'
    -theme-str 'listview {lines: 3;}'
    -mesg "<span size='x-small'>Use <b>Up/Down</b> to preview. <b>Enter</b> to apply. <b>Esc</b> to cancel.</span>"
)

declare -a SHADERS=()
declare ORIGINAL_SHADER=""
declare -i CURRENT_IDX=0
declare -i MAX_IDX=0
declare PREVIEW_SHADER=""
declare SEARCH_QUERY=""
declare CLEANUP_NEEDED="true"

trim() {
    local str="${1:-}"
    str="${str#"${str%%[![:space:]]*}"}"
    str="${str%"${str##*[![:space:]]}"}"
    printf '%s' "$str"
}

err() {
    printf 'Error: %s\n' "$*" >&2
}

check_dependencies() {
    local -a missing=()
    local cmd
    for cmd in rofi hyprshade; do
        command -v "$cmd" &>/dev/null || missing+=("$cmd")
    done
    
    if ((${#missing[@]} > 0)); then
        err "Missing required commands: ${missing[*]}"
        exit 1
    fi
}

apply_shader() {
    local shader="${1:-off}"
    local background="${2:-false}"
    
    local -a cmd=(hyprshade)
    [[ "$shader" == "off" ]] && cmd+=(off) || cmd+=(on "$shader")
    
    if [[ "$background" == "true" ]]; then
        "${cmd[@]}" &>/dev/null &
    else
        "${cmd[@]}"
    fi
}

cleanup() {
    if [[ "$CLEANUP_NEEDED" == "true" && -n "$ORIGINAL_SHADER" ]]; then
        apply_shader "$ORIGINAL_SHADER" 2>/dev/null || true
    fi
}

init() {
    check_dependencies
    
    trap cleanup EXIT INT TERM HUP
    
    ORIGINAL_SHADER=$(trim "$(hyprshade current 2>/dev/null || echo '')")
    [[ -z "$ORIGINAL_SHADER" ]] && ORIGINAL_SHADER="off"
    
    SHADERS=("off")
    local line
    while IFS= read -r line; do
        line=$(trim "$line")
        [[ -n "$line" ]] && SHADERS+=("$line")
    done < <(hyprshade ls 2>/dev/null || true)
    
    if ((${#SHADERS[@]} == 0)); then
        err "No shaders available"
        exit 1
    fi
    
    CURRENT_IDX=0
    local i
    for i in "${!SHADERS[@]}"; do
        if [[ "${SHADERS[i]}" == "$ORIGINAL_SHADER" ]]; then
            CURRENT_IDX=$i
            break
        fi
    done
    
    MAX_IDX=$((${#SHADERS[@]} - 1))
    PREVIEW_SHADER="$ORIGINAL_SHADER"
}

build_menu() {
    local -n menu_ref=$1
    local -n active_ref=$2
    
    menu_ref=()
    active_ref=0
    
    local i item icon prefix suffix display_name
    
    for i in "${!SHADERS[@]}"; do
        item="${SHADERS[i]}"
        prefix="" suffix=""
        
        if [[ "$item" == "off" ]]; then
            icon="${ICONS[off]}"
            display_name="Turn Off"
        else
            icon="${ICONS[shader]}"
            display_name="$item"
        fi

        if [[ "$item" == "$PREVIEW_SHADER" ]]; then
            active_ref=$i
            prefix="<b>"
            suffix=" (Active)</b>"
            icon="${ICONS[active]}" 
        else
            if [[ "$item" != "off" ]]; then
                 icon="${ICONS[inactive]}"
            fi
        fi
        
        menu_ref+=("${prefix}${icon}  ${display_name}${suffix}")
    done
}

main_loop() {
    local -a menu_lines rofi_flags
    local -i active_row_index exit_code
    local raw_output selection returned_query target
    
    while true; do
        build_menu menu_lines active_row_index
        
        rofi_flags=(
            -p "Shader"
            -format "i|f"
            -a "$active_row_index"
        )
        
        if [[ -n "$SEARCH_QUERY" ]]; then
            rofi_flags+=(-filter "$SEARCH_QUERY")
        else
            rofi_flags+=(
                -selected-row "$CURRENT_IDX"
                -kb-custom-1 "Down"
                -kb-custom-2 "Up"
                -kb-row-down ""
                -kb-row-up ""
            )
        fi
        
        set +o errexit
        raw_output=$(printf '%s\n' "${menu_lines[@]}" | "${ROFI_CMD[@]}" "${rofi_flags[@]}" 2>/dev/null)
        exit_code=$?
        set -o errexit
        
        selection="${raw_output%%|*}"
        returned_query="${raw_output#*|}"
        [[ "$raw_output" != *"|"* ]] && returned_query=""
        
        case $exit_code in
            0)
                if [[ "$selection" =~ ^[0-9]+$ ]] && ((selection <= MAX_IDX)); then
                    target="${SHADERS[selection]}"
                else
                    target="$PREVIEW_SHADER"
                fi
                
                apply_shader "$target"
                
                if command -v notify-send &>/dev/null; then
                    local msg=$([[ "$target" == "off" ]] && echo "Off" || echo "$target")
                    notify-send -i video-display "Hyprshade" "Applied: $msg"
                fi
                
                CLEANUP_NEEDED="false"
                exit 0
                ;;
                
            10)
                [[ -n "$returned_query" ]] && { SEARCH_QUERY="$returned_query"; continue; }
                
                ((++CURRENT_IDX > MAX_IDX)) && CURRENT_IDX=0
                PREVIEW_SHADER="${SHADERS[CURRENT_IDX]}"
                SEARCH_QUERY=""
                apply_shader "$PREVIEW_SHADER" true
                ;;
                
            11)
                [[ -n "$returned_query" ]] && { SEARCH_QUERY="$returned_query"; continue; }
                
                ((--CURRENT_IDX < 0)) && CURRENT_IDX=$MAX_IDX
                PREVIEW_SHADER="${SHADERS[CURRENT_IDX]}"
                SEARCH_QUERY=""
                apply_shader "$PREVIEW_SHADER" true
                ;;
                
            1)
                apply_shader "$ORIGINAL_SHADER"
                CLEANUP_NEEDED="false"
                exit 0
                ;;
                
            *)
                err "Rofi exited with unexpected code: $exit_code"
                apply_shader "$ORIGINAL_SHADER"
                CLEANUP_NEEDED="false"
                exit 1
                ;;
        esac
    done
}

main() {
    init
    main_loop
}

main "$@"