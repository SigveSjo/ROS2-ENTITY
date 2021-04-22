#!/usr/bin/env bash
udp_ip=$1
#while true; do raspivid -a 12 -t 0 -w 640 -h 480 -hf -ih -fps 30 -o udp://$udp_ip -cd H264 -n; sleep 5; done

while true; do raspivid -a 12 -a "ras2" -t 0 -b 1000000 -fps 60 -w 640 -h 480 -o udp://$udp_ip -ih -fl -stm -if adaptive -pf main -n; sleep 2; done