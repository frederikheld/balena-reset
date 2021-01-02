#!/bin/sh
for i in 1 2 3 4 5
do
    echo $i
done

echo "---"

counter=0
while [ $counter -lt 5 ]
do
    counter=$((counter+1))
    echo $counter
done

echo "---"

blink_led() {
    PIN=$1
    COUNT=$2
    PAUSE=$3

    counter=0
    while [ $counter -lt $COUNT ]
    do
        counter=$((counter+1))
        echo "PIN: ${PIN}, counter: ${counter}/${COUNT}"
        echo "pausing for ${PAUSE} seconds"
        sleep $PAUSE
    done
}

blink_led 5 3 0.5