#!/bin/bash

CSV_FILE="wifi_metrics.csv"

echo "Timestamp,AccessPoint,Quality,Power,GWLatency,FreeLatency,GWLoss,FreeLoss" > $CSV_FILE

while true; do
    TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S.%3N")
    FREEDNS_IP='212.27.40.240'
    GW_IP='192.168.0.254'

    AP=$(iwconfig 2>&1 | grep 'Access Point' | awk '{print $6}')
    SIGNAL_QUALITY=$(iwconfig 2>&1 | grep 'Link Quality' | awk '{print $4}' | cut -d'=' -f2)
    SIGNAL_POWER=$(iwconfig 2>&1 | grep 'Power' | awk '{print $4}' | cut -d'=' -f2)

    FPING_OUTPUT=$(fping -c 1 -t 100 -I wlan0 192.168.0.254 212.27.40.240 2>&1)
    FPING_LAST_LINES=$(echo "$FPING_OUTPUT" | tail -n 2)

    LATENCY_GW=$(echo "$FPING_LAST_LINES" | grep $GW_IP | awk '{split($8,a,"/"); print a[2]}')
    PACKETLOSS_GW=$(echo "$FPING_LAST_LINES" | grep $GW_IP | awk '{split($5,a,"/"); print a[3]}' | tr -d ',')

    LATENCY_FREE=$(echo "$FPING_LAST_LINES" | grep $FREEDNS_IP | awk '{split($8,a,"/"); print a[2]}')
    PACKETLOSS_FREE=$(echo "$FPING_LAST_LINES" | grep $FREEDNS_IP | awk '{split($5,a,"/"); print a[3]}' | tr -d ',')

    echo "$TIMESTAMP,$AP,$SIGNAL_QUALITY,$SIGNAL_POWER,$LATENCY_GW,$LATENCY_FREE,$PACKETLOSS_GW,$PACKETLOSS_FREE" >> $CSV_FILE
    sleep 0.5
done

