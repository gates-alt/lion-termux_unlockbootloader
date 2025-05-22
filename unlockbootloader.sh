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

cd "$WORKSPACE_DIR" || exit 1

CLEAN_FILES=(.etapa1 .etapa1alt .etapa2 .etapa3 .etapa4 .etapa5)
rm -f "${CLEAN_FILES[@]}"

run_cmd() {
    while true; do
        termux-usb -l > file.txt || continue
        USB_DEVICE=$(grep -o /dev/bus/usb/[0-9]*/[0-9]* file.txt)
        termux-usb -r $USB_DEVICE || continue
        termux-usb -e "$APPS_DIR/spd_dump --usb-fd $1" $USB_DEVICE && break
    done
}

if [ ! -f u-boot-spl-16k-sign.bin ]; then
    run_cmd "loadexec $BIN_DIR/custom_exec_no_verify_65015f08.bin fdl $BIN_DIR/fdl1-dl.bin 0x65000800 fdl $BIN_DIR/fdl2-dl.bin 0x9efffe00 exec r splloader r uboot e splloader e splloader_bak reset"
    touch .etapa1
   
    until "$APPS_DIR/gen_spl-unlock" splloader.bin; do sleep 1; done
    until mv -f splloader.bin u-boot-spl-16k-sign.bin; do sleep 1; done
    until "$APPS_DIR/chsize" uboot.bin; do sleep 1; done
    until mv -f uboot.bin uboot_bak.bin; do sleep 1; done  
else
    
    run_cmd "loadexec $BIN_DIR/custom_exec_no_verify_65015f08.bin fdl $BIN_DIR/fdl1-dl.bin 0x65000800 fdl $BIN_DIR/fdl2-dl.bin 0x9efffe00 exec e splloader e splloader_bak reset"
    touch .etapa1alt
fi

run_cmd "loadexec $BIN_DIR/custom_exec_no_verify_65015f08.bin fdl $BIN_DIR/fdl1-dl.bin 0x65000800 fdl $BIN_DIR/fdl2-dl.bin 0x9efffe00 exec w uboot $BIN_DIR/fdl2-cboot.bin reset"
touch .etapa2

while true; do
    termux-usb -l > file.txt
    USB_DEVICE=$(grep -o /dev/bus/usb/[0-9]*/[0-9]* file.txt)
    termux-usb -r $USB_DEVICE || continue
    
    termux-usb -e "$APPS_DIR/spd_dump --usb-fd loadexec $BIN_DIR/custom_exec_no_verify_65015f08.bin fdl spl-unlock.bin 0x65000800" $USB_DEVICE 2>&1 | tee spd_output.txt
   
    grep -q 'SEND spl-unlock.bin' spd_output.txt && break
done
touch .etapa3

run_cmd "loadexec $BIN_DIR/custom_exec_no_verify_65015f08.bin fdl $BIN_DIR/fdl1-dl.bin 0x65000800 fdl $BIN_DIR/fdl2-dl.bin 0x9efffe00 exec verbose 2 read_part miscdata 8192 64 key reset"
touch .etapa4

run_cmd "loadexec $BIN_DIR/custom_exec_no_verify_65015f08.bin fdl $BIN_DIR/fdl1-dl.bin 0x65000800 fdl $BIN_DIR/fdl2-dl.bin 0x9efffe00 exec r boot w splloader u-boot-spl-16k-sign.bin w uboot uboot_bak.bin w misc $BIN_MISC_DIR/misc-wipe.bin reset"
touch .etapa5
