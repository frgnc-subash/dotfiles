#!/usr/bin/env bash
# ==============================================================================
# WAYCLICK ELITE - SETUP ONLY (ORCHESTRA MODULE)
# ==============================================================================
#  INSTRUCTIONS:
#  Add this to your Orchestra INSTALL_SEQUENCE as a User command:
#  "U | 081_wayclick_setup.sh"
# ==============================================================================

set -euo pipefail

# --- CONFIGURATION ---
readonly APP_NAME="wayclick"
readonly BASE_DIR="$HOME/.contained_apps/uv/$APP_NAME"
readonly VENV_DIR="$BASE_DIR/.venv"
readonly RUNNER_SCRIPT="$BASE_DIR/runner.py"
readonly CONFIG_DIR="$HOME/.config/wayclick"

# --- LOGGING HELPER ---
log() {
    echo " -> [WAYCLICK SETUP] $1"
}

# 1. Dependency Check & Auto-Install
# We rely on the Orchestra's sudo keep-alive for permissions.
NEEDED_DEPS=""
if ! command -v uv &>/dev/null; then NEEDED_DEPS="$NEEDED_DEPS uv"; fi
if ! command -v notify-send &>/dev/null; then NEEDED_DEPS="$NEEDED_DEPS libnotify"; fi

# [FIXED LIST] Critical headers for compiling pygame-ce from source.
# Added 'portmidi' (fixes the specific error you saw) and 'pkgconf' (required for meson).
REQUIRED_LIBS=("sdl2" "sdl2_image" "sdl2_mixer" "sdl2_ttf" "portmidi" "pkgconf" "git")

for pkg in "${REQUIRED_LIBS[@]}"; do
    if ! pacman -Qi "$pkg" &>/dev/null; then
        NEEDED_DEPS="$NEEDED_DEPS $pkg"
    fi
done

if [[ -n "$NEEDED_DEPS" ]]; then
    log "Installing missing native build dependencies: $NEEDED_DEPS"
    # --needed ensures we don't reinstall things, --noconfirm for automation
    if sudo pacman -S --needed --noconfirm $NEEDED_DEPS; then
        log "System dependencies installed successfully."
    else
        log "CRITICAL: Failed to install system dependencies. Build will likely fail."
        exit 1
    fi
else
    log "System dependencies (SDL2 stack, PortMidi, pkgconf) are present."
fi

# 2. Group Permission Check (Input)
if ! groups "$USER" | grep -q "\binput\b"; then
    log "User '$USER' is not in 'input' group. Adding now..."
    sudo usermod -aG input "$USER"
    log "WARNING: You must REBOOT or LOGOUT for group changes to take effect."
else
    log "User is already in 'input' group."
fi

# 3. Directory Structure
if [[ ! -d "$BASE_DIR" ]]; then
    log "Creating base directory: $BASE_DIR"
    mkdir -p "$BASE_DIR"
fi

if [[ ! -d "$CONFIG_DIR" ]]; then
    log "Creating config directory: $CONFIG_DIR"
    mkdir -p "$CONFIG_DIR"
fi

# 4. Environment Setup (UV)
MARKER_FILE="$BASE_DIR/.build_marker_v3"

# Force rebuild if dependencies changed implies we might want to wipe,
# but for now we trust the marker.
if [[ ! -f "$MARKER_FILE" ]]; then
    log "Initializing UV environment..."

    # Create VENV if it doesn't exist
    if [[ ! -d "$VENV_DIR" ]]; then
        uv venv "$VENV_DIR" --python 3.13 --quiet
    fi

    log "Compiling dependencies with NATIVE CPU FLAGS (AVX2+)..."
    log "NOTE: This may take a moment as we are compiling C extensions."

    # ---------------------------------------------------------
    # ELITE BUILD FLAGS
    # ---------------------------------------------------------
    export CFLAGS="-march=native -mtune=native -O3 -pipe -fno-plt"
    export CXXFLAGS="-march=native -mtune=native -O3 -pipe -fno-plt"

    # Install evdev and pygame-ce from source
    # We explicitly use the venv python to ensure paths are correct
    if uv pip install --python "$VENV_DIR/bin/python" \
        --no-binary :all: \
        --compile-bytecode \
        evdev pygame-ce; then

        touch "$MARKER_FILE"
        log "Native build complete."
    else
        log "CRITICAL: Build failed. Check if 'portmidi' or 'sdl2_mixer' are missing."
        exit 1
    fi
else
    log "Environment already built (Marker found). Skipping build."
fi

# 5. Generate Runner Script
log "Generating runner.py..."

cat >"$RUNNER_SCRIPT" <<'EOF'
import asyncio
import os
import sys
import signal
import random
import json

# === PERFORMANCE FLAGS ===
os.environ['PYGAME_HIDE_SUPPORT_PROMPT'] = '1'
os.environ['SDL_BUFFER_CHUNK_SIZE'] = '256' 

import pygame
import evdev
from evdev import ecodes

# ANSI Colors
C_GREEN = "\033[1;32m"
C_YELLOW = "\033[1;33m"
C_BLUE = "\033[1;34m"
C_RED = "\033[1;31m"
C_RESET = "\033[0m"

ASSET_DIR = sys.argv[1]
ENABLE_TRACKPADS = os.environ.get('ENABLE_TRACKPADS', 'false').lower() == 'true'

# === AUDIO INIT ===
try:
    pygame.mixer.pre_init(frequency=44100, size=-16, channels=2, buffer=256)
    pygame.mixer.init()
    pygame.mixer.set_num_channels(32)
except pygame.error as e:
    print(f"\033[1;31m[AUDIO ERROR]\033[0m {e}")
    sys.exit(1)

# === CONFIG LOADING ===
CONFIG_FILE = os.path.join(ASSET_DIR, "config.json")
print(f"{C_BLUE}[INFO]{C_RESET} Loading assets from {ASSET_DIR}...")

try:
    with open(CONFIG_FILE, 'r') as f:
        config_data = json.load(f)
        RAW_KEY_MAP = {int(k): v for k, v in config_data.get("mappings", {}).items()}
        DEFAULTS = config_data.get("defaults", [])
        
except Exception as e:
    print(f"{C_RED}[CONFIG ERROR]{C_RESET} Failed to load {CONFIG_FILE}: {e}")
    sys.exit(1)

SOUND_FILES = list(set(list(RAW_KEY_MAP.values()) + DEFAULTS))
SOUNDS = {}

for filename in SOUND_FILES:
    path = os.path.join(ASSET_DIR, filename)
    if os.path.exists(path):
        try:
            SOUNDS[filename] = pygame.mixer.Sound(path)
        except pygame.error:
            print(f"{C_YELLOW}[WARN]{C_RESET} Failed to load wav: {filename}")
    else:
        print(f"{C_YELLOW}[WARN]{C_RESET} File not found: {filename}")

if not SOUNDS:
    sys.exit("ERROR: No sounds loaded! Check your config.json and .wav files.")

# === OPTIMIZATION: CACHED LIST LOOKUP ===
MAX_KEYCODE = 65536
SOUND_CACHE = [None] * MAX_KEYCODE
DEFAULT_SOUND_OBJS = [SOUNDS[f] for f in DEFAULTS if f in SOUNDS]

for code, filename in RAW_KEY_MAP.items():
    if code < MAX_KEYCODE and filename in SOUNDS:
        SOUND_CACHE[code] = SOUNDS[filename]

_random_choice = random.choice

def play_sound(code):
    if code < MAX_KEYCODE:
        sound = SOUND_CACHE[code]
        if sound:
            sound.play()
            return

    if DEFAULT_SOUND_OBJS:
        _random_choice(DEFAULT_SOUND_OBJS).play()

async def read_device(path, stop_event):
    dev = None
    try:
        dev = evdev.InputDevice(path)
        print(f"{C_GREEN}[+] Connected:{C_RESET} {dev.name}")
        
        async for event in dev.async_read_loop():
            if stop_event.is_set():
                break
            if event.type == 1 and event.value == 1:
                play_sound(event.code)
                
    except (OSError, IOError):
        print(f"{C_YELLOW}[-] Disconnected:{C_RESET} {path}")
    except asyncio.CancelledError:
        pass
    finally:
        if dev:
            dev.close()

async def main():
    print(f"{C_BLUE}[CORE]{C_RESET} Engine started. Monitoring devices...")
    
    stop = asyncio.Event()
    loop = asyncio.get_running_loop()
    
    for sig in (signal.SIGINT, signal.SIGTERM):
        loop.add_signal_handler(sig, stop.set)
    
    monitored_tasks = {}

    while not stop.is_set():
        try:
            all_paths = evdev.list_devices()
            
            for path in all_paths:
                if path in monitored_tasks:
                    continue
                
                try:
                    dev = evdev.InputDevice(path)
                    
                    if not ENABLE_TRACKPADS:
                        name_lower = dev.name.lower()
                        if 'touchpad' in name_lower or 'trackpad' in name_lower:
                            dev.close()
                            continue

                    caps = dev.capabilities()
                    if 1 in caps:
                        task = asyncio.create_task(read_device(path, stop))
                        monitored_tasks[path] = task
                    dev.close()
                except (OSError, IOError):
                    continue

        except Exception as e:
            print(f"Discovery Loop Error: {e}")

        dead_paths = [p for p, t in monitored_tasks.items() if t.done()]
        for p in dead_paths:
            del monitored_tasks[p]

        try:
            await asyncio.wait_for(stop.wait(), timeout=3.0)
        except asyncio.TimeoutError:
            continue
    
    print("\nStopping...")
    for t in monitored_tasks.values():
        t.cancel()
    if monitored_tasks:
        await asyncio.gather(*monitored_tasks.values(), return_exceptions=True)
    pygame.mixer.quit()

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        pass
EOF

log "Setup complete. Wayclick environment is ready."
