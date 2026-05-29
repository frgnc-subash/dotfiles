#!/usr/bin/env bash
set -euo pipefail

# SwayOSD restart helper — Hyprland/Arch edition
# Handles environment-aware server spawning so OSD actually works
# after a theme reload or manual restart.

readonly SERVER_BIN="${SWAYOSD_SERVER_BIN:-/usr/bin/swayosd-server}"
readonly PROCESS_NAME="${SWAYOSD_PROCESS_NAME:-swayosd-server}"
readonly LOCK_DIR="$([[ -w "${XDG_RUNTIME_DIR:-}" ]] && printf '%s' "$XDG_RUNTIME_DIR" || printf /tmp)"
readonly LOCK_FILE="$LOCK_DIR/swayosd-restart.lock"

readonly TERM_ATTEMPTS=16
readonly KILL_ATTEMPTS=8
readonly START_ATTEMPTS=24
readonly POLL_INTERVAL=0.025

log_error() { printf 'Error: %s\n' "$*" >&2; }
log_warn() { printf 'Warning: %s\n' "$*" >&2; }
log_success() { printf 'Success: %s\n' "$*"; }

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

# Build a minimal but sufficient environment for SwayOSD.
# The server needs WAYLAND_DISPLAY and DBUS_SESSION_BUS_ADDRESS at minimum;
# without them it silently starts but can't render anything.
build_env() {
    local -a env_vars=(
        WAYLAND_DISPLAY
        DISPLAY
        DBUS_SESSION_BUS_ADDRESS
        XDG_RUNTIME_DIR
        XDG_CURRENT_DESKTOP
        XDG_SESSION_TYPE
        HOME
        USER
        PATH
    )
    local -a env_args=()
    for var in "${env_vars[@]}"; do
        [[ -n "${!var:-}" ]] && env_args+=("$var=${!var}")
    done
    printf '%s\n' "${env_args[@]}"
}

start_server() {
    # Prefer systemd-run so the process is properly scoped, survives the
    # script, and inherits a clean but complete environment.
    if command -v systemd-run >/dev/null 2>&1; then
        local -a env_args=()
        while IFS= read -r kv; do
            env_args+=(--setenv="$kv")
        done < <(build_env)

        systemd-run \
            --user \
            --scope \
            --quiet \
            --collect \
            --unit="swayosd-reload-$$" \
            "${env_args[@]}" \
            -- "$SERVER_BIN" >/dev/null 2>&1 &
        disown 2>/dev/null || true
        return 0
    fi

    # Fallback: uwsm-app (common on Hyprland with uwsm session manager)
    if command -v uwsm-app >/dev/null 2>&1; then
        uwsm-app -- "$SERVER_BIN" >/dev/null 2>&1 &
        disown 2>/dev/null || true
        return 0
    fi

    # Last resort: plain setsid. Environment is inherited from the caller,
    # which is usually fine when invoked from a Hyprland exec binding.
    setsid "$SERVER_BIN" >/dev/null 2>&1 &
    disown 2>/dev/null || true
}

# ── Sanity checks ────────────────────────────────────────────────────────────

if [[ ! -x "$SERVER_BIN" ]]; then
    log_error "Server binary not found or not executable: $SERVER_BIN"
    exit 1
fi

if [[ -z "${WAYLAND_DISPLAY:-}" ]]; then
    log_warn "WAYLAND_DISPLAY is not set — OSD may not render correctly"
fi

if [[ -z "${DBUS_SESSION_BUS_ADDRESS:-}" ]]; then
    log_warn "DBUS_SESSION_BUS_ADDRESS is not set — OSD may not render correctly"
fi

# ── Lock: only one reload in flight at a time ────────────────────────────────

exec 9>"$LOCK_FILE"
if ! flock -n 9; then
    # Another reload is already running; exit cleanly so rapid hook
    # invocations don't race and kill each other's freshly started server.
    exit 0
fi

# ── Stop existing instance ───────────────────────────────────────────────────

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

# ── Start new instance ───────────────────────────────────────────────────────

start_server

if wait_for_start; then
    log_success "SwayOSD server restarted successfully"
else
    log_error "SwayOSD server failed to start within timeout"
    exit 1
fi
