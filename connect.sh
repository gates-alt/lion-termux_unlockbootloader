termux-wake-lock

reset_usb() {
    MODEL=$(getprop ro.product.model | tr '[:upper:]' '[:lower:]')
    SOC=$(getprop ro.boot.hardware || getprop ro.board.platform | tr '[:upper:]' '[:lower:]')
    KERNEL_VER=$(uname -r | cut -d '.' -f1-2)

    echo "product: $MODEL"
    echo "soc: $SOC"
    echo "kernel: $KERNEL_VER"
    
    NEED_RESET=0

    if [[ "$MODEL" == *"moto g20"* || "$MODEL" == *"moto e40"* ]]; then
        NEED_RESET=1
    elif [[ "$SOC" == *"ums512"* || "$SOC" == *"unisoc_t700"* || "$SOC" == *"t700"* ]]; then
        NEED_RESET=1
    elif [[ $(echo "$KERNEL_VER < 4.4" | bc) -eq 1 ]]; then
        NEED_RESET=1
    fi

    if [ "$NEED_RESET" -ne 1 ]; then
        echo "reset USB não necessário neste dispositivo."
        return
    fi

    echo "aguardando conexão USB por até 30 segundos..."

    for i in $(seq 1 30); do
        USB_DEVS=$(su -c ls /sys/bus/usb/devices/ | grep -E '^[0-9]+-[0-9]+$')
        if [ -n "$USB_DEVS" ]; then
            echo "dispositivo: $USB_DEVS"
            break
        fi
        sleep 1
    done

    if [ -z "$USB_DEVS" ]; then
        echo "nenhun dispositivo USB detectado após 30 segundos. abortando"
        exit 1
    fi

    echo "reset Android subsistema USB do kernel..."

    for dev in $USB_DEVS; do
        su -c "echo -n '$dev' > /sys/bus/usb/drivers/usb/unbind"
        sleep 1
        su -c "echo -n '$dev' > /sys/bus/usb/drivers/usb/bind"
    done

    echo "reset USB concluído. continuando..."
}

run_cmd() {
    while true; do
        termux-usb -l > file.txt || continue
        USB_DEVICE=$(grep -o /dev/bus/usb/[0-9]*/[0-9]* file.txt)
        termux-usb -r $USB_DEVICE || continue
        termux-usb -e "./apps/spd_dump --usb-fd $1" $USB_DEVICE && break
    done
}

reset_usb
run_cmd "loadexec bin/custom_exec_no_verify_65015f08.bin fdl bin/fdl1-dl.bin 0x65000800 fdl bin/fdl2-dl.bin 0x9efffe00 exec"
