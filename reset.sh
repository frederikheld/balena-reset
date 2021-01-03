#!/bin/bash

# -- config

SERIAL_OUT=/dev/ttyS0

# -- setup

echo "${GPIO_RESET_IN}" > /sys/class/gpio/export
echo "in" > /sys/class/gpio/gpio${GPIO_RESET_IN}/direction

echo "${GPIO_ACK_OUT}" > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio${GPIO_ACK_OUT}/direction
echo "0" > /sys/class/gpio/gpio${GPIO_ACK_OUT}/value

export DBUS_SYSTEM_BUS_ADDRESS=unix:path=/host/run/dbus/system_bus_socket

# -- functions

# Blinks the LED on the given pin
#
# $ blink_led pin count pause
#
# pin: pin
# count: number of blinks
# pause: time between blinks
blink_led() {
    PIN=$1
    COUNT=$2
    PAUSE=$3

    counter=0
    while [ $counter -lt $COUNT ]
    do
        counter=$((counter+1))
        echo "1" > /sys/class/gpio/gpio${PIN}/value
        sleep $PAUSE
        echo "0" > /sys/class/gpio/gpio${PIN}/value
        sleep $PAUSE
    done
}

# -- main

# exit if button is not pressed:
value=$(cat /sys/class/gpio/gpio${GPIO_RESET_IN}/value)
if [ $value -eq 0 ]
then
    echo "Reset button not pressed. No stored WiFi connections will be deleted." | tee $SERIAL_OUT
    exit 0
fi

# collect uuids of all wifi connections:
uuids=$(nmcli connection show | awk '{if ($3 == "wifi") print $2;}')

# delete each of them individually:
counter=0
for line in $uuids
do
    echo "Deleting $line" | tee $SERIAL_OUT
    nmcli connection delete $line # see IMPORTANT NOTE below
    counter=$((counter+1))
done

# IMPORTANT NOTE: If you debug this script on your computer, comment out this line! Otherwise it will delete all your stored WiFi connections which is most probably not what you want!

plural_suffix=""
if [ $counter -gt 1 ]
then
    plural_suffix="s"
fi

echo "Deleted ${counter} stored WiFi connection${plural_suffix}." | tee $SERIAL_OUT
blink_led ${GPIO_ACK_OUT} 3 0.2

exit 0