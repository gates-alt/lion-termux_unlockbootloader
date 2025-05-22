termux-wake-lock

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$SCRIPT_DIR/workspace"
APPS_DIR="$SCRIPT_DIR/apps"
BIN_DIR="$SCRIPT_DIR/bin"
BIN_MISC_DIR="$SCRIPT_DIR/bin_misc"

if [ ! -d "$WORKSPACE_DIR" ]; then
    echo "workspace folder not found. creating..."
    mkdir -p "$WORKSPACE_DIR"
else
    echo "workspace folder already exists."
fi

run_cmd "loadexec $BIN_DIR/custom_exec_no_verify_65015f08.bin fdl $BIN_DIR/fdl1-dl.bin 0x65000800 fdl $BIN_DIR/fdl2-dl.bin 0x9efffe00 exec wof miscdata 8192 $BIN_MISC_DIR/zero.bin verity 1 w misc $BIN_MISC_DIR/misc-wipe.bin reset"
