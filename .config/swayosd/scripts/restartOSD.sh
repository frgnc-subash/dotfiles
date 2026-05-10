#!/usr/bin/env bash

set -euo pipefail

# Fast SwayOSD restart helper. Tuned for theme reload hooks where the caller
# should get control back as soon as the new server is actually alive.

readonly SERVER_BIN="${SWAYOSD_SERVER_BIN:-/usr/bin/swayosd-server}"
readonly PROCESS_NAME="${SWAYOSD_PROCESS_NAME:-swayosd-server}"
readonly LOCK_DIR="$([[ -w "${XDG_RUNTIME_DIR:-}" ]] && printf '%s' "$XDG_RUNTIME_DIR" || printf /tmp)"
readonly LOCK_FILE="$LOCK_DIR/swayosd-restart.lock"

readonly TERM_ATTEMPTS=16
readonly KILL_ATTEMPTS=8
readonly START_ATTEMPTS=24
readonly POLL_INTERVAL=0.025

log_error() {
    printf 'Error: %s\n' "$*" >&2
}

log_success() {
    printf 'Success: %s\n' "$*"
}

is_running() {
    pgrep -x "$PROCESS_NAME" >/dev/null 2>&1
}

wait_for_stop() {
    local attempts="$1"

    for ((_i = 0; _i < attempts; _i++)); do
        is_running || return 0
        sleep "$POLL_INTERVAL"
    done

    is_running && return 1
    return 0
}

wait_for_start() {
    for ((_i = 0; _i < START_ATTEMPTS; _i++)); do
        is_running && return 0
        sleep "$POLL_INTERVAL"
    done

    is_running
}

start_server() {
    if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]] && command -v hyprctl >/dev/null 2>&1; then
        hyprctl dispatch exec "$SERVER_BIN" >/dev/null 2>&1 && return 0
    fi

    if command -v uwsm-app >/dev/null 2>&1; then
        uwsm-app -- "$SERVER_BIN" >/dev/null 2>&1 &
    elif command -v systemd-run >/dev/null 2>&1; then
        systemd-run --user --scope --quiet --collect \
            --unit="swayosd-reload-$$" -- "$SERVER_BIN" >/dev/null 2>&1 &
    else
        setsid "$SERVER_BIN" >/dev/null 2>&1 &
    fi

    disown 2>/dev/null || true
}

if [[ ! -x "$SERVER_BIN" ]]; then
    log_error "Server binary not found or not executable: $SERVER_BIN"
    exit 1
fi

exec 9>"$LOCK_FILE"
if ! flock -n 9; then
    # A reload is already in flight. Returning cleanly keeps rapid hooks snappy
    # and avoids two scripts killing each other's freshly started server.
    exit 0
fi

if is_running; then
    pkill -TERM -x "$PROCESS_NAME" 2>/dev/null || true

    if ! wait_for_stop "$TERM_ATTEMPTS"; then
        pkill -KILL -x "$PROCESS_NAME" 2>/dev/null || true
        wait_for_stop "$KILL_ATTEMPTS" || {
            log_error "Failed to terminate existing $PROCESS_NAME process"
            exit 1
        }
    fi
fi

start_server

if wait_for_start; then
    log_success "SwayOSD server restarted"
else
    log_error "SwayOSD server failed to start"
    exit 1
fi
