#!/bin/bash

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
    echo "Reset button not pressed. No stored WiFi connections deleted."
    echo "Terminating."
    exit 0
fi

# collect uuids of all wifi connections:
uuids=$(nmcli connection show | awk '{if ($3 == "wifi") print $2;}')

# delete each of them individually:
counter=0
for line in $uuids
do
    echo "Deleting $line"
    counter=$((counter+1))
done

echo "(not actually) Deleted ${counter} stored WiFi connections."
blink_led ${GPIO_ACK_OUT} 3 0.2
