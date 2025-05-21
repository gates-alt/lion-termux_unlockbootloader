termux-wake-lock

while true; do
    termux-usb -l > file.txt || continue
    USB_DEVICE=$(grep -o /dev/bus/usb/[0-9]*/[0-9]* file.txt)
    termux-usb -r $USB_DEVICE || continue
    termux-usb -e "/spd_dump --usb-fd loadexec bin/custom_exec_no_verify_65015f08.bin fdl bin/fdl1-dl.bin 0x65000800 fdl bin/fdl2-dl.bin 0x9efffe00 exec w misc bin/misc-wipe.bin reset" $USB_DEVICE || continue
done
