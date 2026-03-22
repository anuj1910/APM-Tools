#!/bin/bash


IP="192.168.204.13"
INTERFACE="ens192"
DISK="sda"

START_TIME=$(date +%s)

rm -f APM*_metrics.csv system_metrics.csv

for i in {1..6}; do
    echo "time,cpu,mem" > "APM${i}_metrics.csv"
done

echo "time,RX,TX,disk_write,disk_space" > system_metrics.csv


spawn_apps() {
    echo "Starting APM applications..."

    ./APM1 $IP & PID1=$!
    ./APM2 $IP & PID2=$!
    ./APM3 $IP & PID3=$!
    ./APM4 $IP & PID4=$!
    ./APM5 $IP & PID5=$!
    ./APM6 $IP & PID6=$!

    PIDS=($PID1 $PID2 $PID3 $PID4 $PID5 $PID6)
}


collect_process_metrics() {

    CURRENT_TIME=$(($(date +%s) - START_TIME))

    for i in "${!PIDS[@]}"; do
        PID=${PIDS[$i]}
        APP_NAME="APM$((i+1))"

        STATS=$(ps -p $PID -o %cpu,%mem --no-headers)

        CPU=$(echo $STATS | awk '{print $1}')
        MEM=$(echo $STATS | awk '{print $2}')

        echo "$CURRENT_TIME,$CPU,$MEM" >> "${APP_NAME}_metrics.csv"
    done
}


collect_system_metrics() {

    CURRENT_TIME=$(($(date +%s) - START_TIME))

    # Network
    NET=$(ifstat -i $INTERFACE 1 1 | tail -1)
    RX=$(echo $NET | awk '{print $1}')
    TX=$(echo $NET | awk '{print $2}')

    # Disk write
    DISK_STATS=$(iostat -d 1 1 | grep $DISK | tail -1)
    DISK_WRITE=$(echo $DISK_STATS | awk '{print $3}')

    # Disk space
    DISK_SPACE=$(df -m / | tail -1 | awk '{print $4}')

    echo "$CURRENT_TIME,$RX,$TX,$DISK_WRITE,$DISK_SPACE" >> system_metrics.csv
}


cleanup() {
    echo "Stopping processes..."
    for PID in "${PIDS[@]}"; do
        kill $PID 2>/dev/null
    done
    exit 0
}

trap cleanup SIGINT


spawn_apps

while true; do
    collect_process_metrics
    collect_system_metrics
    sleep 5
done
