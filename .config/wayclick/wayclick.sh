#!/usr/bin/env bash
# ==============================================================================
# WAYCLICK ELITE - ARCH LINUX / UV OPTIMIZED
# ==============================================================================
# "I fear not the man who has practiced 10,000 kicks once,
#  but I fear the man who has practiced one kick 10,000 times." - Bruce Lee
# ==============================================================================

set -euo pipefail
export TERM=linux
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
trap cleanup EXIT INT TERM

# --- CONFIGURATION ---
readonly APP_NAME="wayclick"
readonly CONFIG_ENABLE_TRACKPADS="false"
readonly BASE_DIR="$HOME/.contained_apps/uv/$APP_NAME"
readonly VENV_DIR="$BASE_DIR/.venv"
readonly RUNNER_SCRIPT="$BASE_DIR/runner.py"
readonly CONFIG_DIR="$HOME/.config/wayclick"

# --- ANSI COLORS ---
readonly C_RED=$'\033[1;31m'
readonly C_GREEN=$'\033[1;32m'
readonly C_BLUE=$'\033[1;34m'
readonly C_CYAN=$'\033[1;36m'
readonly C_YELLOW=$'\033[1;33m'
readonly C_DIM=$'\033[2m'
readonly C_RESET=$'\033[0m'

cleanup() {
    tput cnorm 2>/dev/null || true
}

# --- CHECKS & TOGGLE LOGIC ---

# 0. Root Check (Safety)
if [[ $EUID -eq 0 ]]; then
    printf "%b[CRITICAL]%b Do not run this script as root. Run as normal user.\n" "${C_RED}" "${C_RESET}"
    exit 1
fi

# 1. Toggle Logic
if pgrep -f "$RUNNER_SCRIPT" >/dev/null; then
    printf "%b[TOGGLE]%b Stopping active instance...\n" "${C_YELLOW}" "${C_RESET}"

    # Notify user
    command -v notify-send >/dev/null && notify-send --app-name="WayClick" "WayClick Elite" "Disabled"

    # Kill the process
    pkill -f "$RUNNER_SCRIPT"

    # Wait loop to ensure audio device is released
    while pgrep -f "$RUNNER_SCRIPT" >/dev/null; do
        sleep 0.1
    done

    exit 0
fi

# 2. Interactive Mode Detection
if [[ -t 0 ]]; then
    INTERACTIVE=true
else
    INTERACTIVE=false
fi

notify_user() {
    if command -v notify-send >/dev/null; then
        notify-send --app-name="WayClick" "WayClick Elite" "$1"
    fi
}

# 3. Dependency Check & Auto-Install (Patched for Native Compilation)
NEEDED_DEPS=""

# Check tools
if ! command -v uv &>/dev/null; then NEEDED_DEPS="$NEEDED_DEPS uv"; fi
if ! command -v notify-send &>/dev/null; then NEEDED_DEPS="$NEEDED_DEPS libnotify"; fi
if ! command -v pkg-config &>/dev/null; then NEEDED_DEPS="$NEEDED_DEPS pkgconf"; fi

# Check libraries required for Compiling Pygame-CE from source
# (Arch Linux package names)
if ! pacman -Qi sdl2 &>/dev/null; then NEEDED_DEPS="$NEEDED_DEPS sdl2"; fi
if ! pacman -Qi sdl2_mixer &>/dev/null; then NEEDED_DEPS="$NEEDED_DEPS sdl2_mixer"; fi
if ! pacman -Qi sdl2_image &>/dev/null; then NEEDED_DEPS="$NEEDED_DEPS sdl2_image"; fi
if ! pacman -Qi sdl2_ttf &>/dev/null; then NEEDED_DEPS="$NEEDED_DEPS sdl2_ttf"; fi

if [[ -n "$NEEDED_DEPS" ]]; then
    if $INTERACTIVE; then
        clear
        printf "%b
╔══════════════════════════════════════════════════════════════╗
║  %bWAYCLICK ELITE%b                                            ║
║  %bHotplug • User Mode • Native AVX2 • Contained%b             ║
╚══════════════════════════════════════════════════════════════╝
%b" "${C_CYAN}" "${C_GREEN}" "${C_CYAN}" "${C_DIM}" "${C_CYAN}" "${C_RESET}"

        printf "%b[SETUP]%b Missing build dependencies:%b%s%b\n" "${C_YELLOW}" "${C_RESET}" "${C_CYAN}" "$NEEDED_DEPS" "${C_RESET}"
        printf "       These are required to compile audio drivers natively.\n"
        printf "       Requesting sudo to install via pacman...\n"

        if sudo pacman -S --needed $NEEDED_DEPS; then
            printf "%b[SUCCESS]%b Dependencies installed.\n" "${C_GREEN}" "${C_RESET}"
        else
            printf "%b[ERROR]%b Installation failed.\n" "${C_RED}" "${C_RESET}"
            exit 1
        fi
    else
        notify_user "Missing dependencies ($NEEDED_DEPS). Run in terminal first."
        exit 1
    fi
fi

# 4. Group Permission Check (Input)
if ! groups "$USER" | grep -q "\binput\b"; then
    if $INTERACTIVE; then
        printf "%b[PERM]%b User '%s' is not in the 'input' group.\n" "${C_RED}" "${C_RESET}" "$USER"
        read -p "Run 'sudo usermod -aG input $USER'? [Y/n] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            sudo usermod -aG input "$USER"
            printf "%b[INFO]%b Group added. %bLOGOUT REQUIRED%b for changes to apply.\n" "${C_GREEN}" "${C_RESET}" "${C_RED}" "${C_RESET}"
            exit 0
        else
            exit 1
        fi
    else
        notify_user "Permission error: User not in 'input' group. Run in terminal."
        exit 1
    fi
fi

# 5. Sound Files Check
check_sounds() {
    [[ -d "$CONFIG_DIR" ]] || return 1
    [[ -f "${CONFIG_DIR}/config.json" ]] || return 1
    return 0
}

if ! check_sounds; then
    if $INTERACTIVE; then
        while ! check_sounds; do
            printf "\n%b[ACTION REQUIRED]%b Missing config.json in: %s\n" "${C_YELLOW}" "${C_RESET}" "${CONFIG_DIR}"
            [[ -d "$CONFIG_DIR" ]] || mkdir -p "$CONFIG_DIR"
            printf "       Please ensure 'config.json' exists in this folder.\n"
            printf "       %bPress Enter to re-scan...%b" "${C_DIM}" "${C_RESET}"
            read -r
        done
        printf "%b[CHECK]%b Configuration found.\n" "${C_GREEN}" "${C_RESET}"
    else
        notify_user "Missing config.json in ~/.config/wayclick. Run in terminal."
        exit 1
    fi
fi

# --- ENVIRONMENT SETUP (The Elite Part) ---

# Create directory structure
if [[ ! -d "$BASE_DIR" ]]; then
    printf "%b[INIT]%b Creating contained environment: %s\n" "${C_BLUE}" "${C_RESET}" "$BASE_DIR"
    mkdir -p "$BASE_DIR"
fi

# Check if VENV exists
if [[ ! -d "$VENV_DIR" ]]; then
    if ! $INTERACTIVE; then
        notify_user "Environment not built! Run in terminal once to initialize."
        exit 1
    fi
    printf "%b[BUILD]%b Initializing UV environment...\n" "${C_BLUE}" "${C_RESET}"
    uv venv "$VENV_DIR" --python 3.13 --quiet
fi

# Check dependencies.
MARKER_FILE="$BASE_DIR/.build_marker_v3"

if [[ ! -f "$MARKER_FILE" ]]; then
    if ! $INTERACTIVE; then
        notify_user "First run setup required! Run in terminal to build native extensions."
        exit 1
    fi

    printf "%b[BUILD]%b Compiling dependencies with NATIVE CPU FLAGS (AVX2+)...\n" "${C_YELLOW}" "${C_RESET}"
    printf "       %bThis runs ON THE METAL. No generic binaries allowed.%b\n" "${C_DIM}" "${C_RESET}"

    # ---------------------------------------------------------
    # ELITE BUILD FLAGS
    # -march=native: Use all instructions available on THIS CPU
    # -O3: Maximum optimization
    # -fno-plt: Faster dynamic linking calls
    # ---------------------------------------------------------
    export CFLAGS="-march=native -mtune=native -O3 -pipe -fno-plt"
    export CXXFLAGS="-march=native -mtune=native -O3 -pipe -fno-plt"

    # Install evdev and pygame-ce from source
    # The script should now have ensured SDL2_mixer is installed on host
    uv pip install --python "$VENV_DIR/bin/python" \
        --no-binary :all: \
        --compile-bytecode \
        evdev pygame-ce

    touch "$MARKER_FILE"
    printf "%b[SUCCESS]%b Native build complete.\n" "${C_GREEN}" "${C_RESET}"
fi

# --- PYTHON RUNNER GENERATION ---
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

# --- EXECUTION ---
printf "%b[RUN]%b Starting engine...\n" "${C_BLUE}" "${C_RESET}"

if ! $INTERACTIVE; then
    notify_user "Enabled"
fi

ENABLE_TRACKPADS="$CONFIG_ENABLE_TRACKPADS" "$VENV_DIR/bin/python" -O "$RUNNER_SCRIPT" "$CONFIG_DIR"

printf "\n%b[INFO]%b WayClick stopped.\n" "${C_BLUE}" "${C_RESET}"
