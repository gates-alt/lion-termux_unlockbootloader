termux-wake-lock

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
USER_PATH="./SPRD_BKP_${TIMESTAMP}_FULL"
mkdir -p $USER_PATH

LATEST_PTABLE=$(ls -t ./partition* ./partitions* 2>/dev/null | head -n 1)

run_cmd() {
    while true; do
        termux-usb -l > file.txt || continue
        USB_DEVICE=$(grep -o /dev/bus/usb/[0-9]*/[0-9]* file.txt)
        termux-usb -r $USB_DEVICE || continue
        termux-usb -e "./apps/spd_dump --usb-fd $1" $USB_DEVICE && break
    done
}

run_cmd "loadexec bin/custom_exec_no_verify_65015f08.bin fdl bin/fdl1-dl.bin 0x65000800 fdl bin/fdl2-dl.bin 0x9efffe00 exec path $USER_PATH read_parts $LATEST_PTABLE reset"
