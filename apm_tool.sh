#!/bin/bash

IP="192.168.204.13"     

INTERFACE="ens192"

START_TIME=$(date +%s)

PIDS=()
NAMES=()

cleanup() {
    echo "Cleaning up..."
    for pid in "${PIDS[@]}"; do
        kill $pid 2>/dev/null
    done
    exit
}

trap cleanup EXIT


spawn_apps() {
    for i in {1..6}; do
        ./APM$i $IP &
        PIDS+=($!)
        NAMES+=("APM$i")
    done
}


collect_process_metrics() {
    NEXT_TIME=$(date +%s)

    while true; do
        CURRENT_TIME=$(($(date +%s) - START_TIME))

        for i in "${!PIDS[@]}"; do
            PID=${PIDS[$i]}
            NAME=${NAMES[$i]}

            if ps -p $PID > /dev/null 2>&1; then
                STATS=$(ps -p $PID -o %cpu=,%mem=)
                CPU=$(echo $STATS | awk '{print $1}')
                MEM=$(echo $STATS | awk '{print $2}')

                echo "$CURRENT_TIME,$CPU,$MEM" >> ${NAME}_metrics.csv
            fi
        done

  
        NEXT_TIME=$((NEXT_TIME + 5))
        NOW=$(date +%s)
        SLEEP_TIME=$((NEXT_TIME - NOW))

        if [ $SLEEP_TIME -gt 0 ]; then
            sleep $SLEEP_TIME
        fi
    done
}


collect_system_metrics() {
    NEXT_TIME=$(date +%s)

    while true; do
        CURRENT_TIME=$(($(date +%s) - START_TIME))

        RX_TOTAL=0
        TX_TOTAL=0


        for i in {1..5}; do
            NET=$(ifstat -i $INTERFACE 1 1 | tail -1)
            RX=$(echo $NET | awk '{print $1}')
            TX=$(echo $NET | awk '{print $2}')

            RX_TOTAL=$(echo "$RX_TOTAL + $RX" | bc)
            TX_TOTAL=$(echo "$TX_TOTAL + $TX" | bc)
        done

        RX_AVG=$(echo "scale=2; $RX_TOTAL / 5" | bc)
        TX_AVG=$(echo "scale=2; $TX_TOTAL / 5" | bc)

        DISK=$(iostat -d 1 2 | grep sda | tail -1 | awk '{print $4}')
        AVAIL=$(df -m / | tail -1 | awk '{print $4}')

        echo "$CURRENT_TIME,$RX_AVG,$TX_AVG,$DISK,$AVAIL" >> system_metrics.csv

        
        NEXT_TIME=$((NEXT_TIME + 5))
        NOW=$(date +%s)
        SLEEP_TIME=$((NEXT_TIME - NOW))

        if [ $SLEEP_TIME -gt 0 ]; then
            sleep $SLEEP_TIME
        fi
    done
}


spawn_apps

collect_process_metrics &
collect_system_metrics &

wait 


