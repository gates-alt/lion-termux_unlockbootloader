termux-wake-lock

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$SCRIPT_DIR/workspace"
APPS_DIR="$SCRIPT_DIR/apps"
BIN_DIR="$SCRIPT_DIR/bin"

if [ ! -d "$WORKSPACE_DIR" ]; then
    echo "workspace folder not found. creating..."
    mkdir -p "$WORKSPACE_DIR"
else
    echo "workspace folder already exists."
fi

run_cmd() {
    cd "$WORKSPACE_DIR" || exit 1

    while true; do
        termux-usb -l > file.txt || continue
        USB_DEVICE=$(grep -o /dev/bus/usb/[0-9]*/[0-9]* file.txt)
        termux-usb -r $USB_DEVICE || continue
        termux-usb -e "$APPS_DIR/spd_dump --usb-fd $1" $USB_DEVICE && break
    done
}

run_cmd "loadexec $BIN_DIR/custom_exec_no_verify_65015f08.bin fdl $BIN_DIR/fdl1-dl.bin 0x65000800 fdl $BIN_DIR/fdl2-dl.bin 0x9efffe00 exec"
