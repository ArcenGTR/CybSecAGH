#!/bin/bash

if [[ $# -ne 2 ]]; 
then
    echo "Error: Exactly two argument are required."
    echo "Usage: $0 <cpu_threshold> <mem_threshold>"
    exit 1
fi

cpu_threshold="$1"
mem_threshold="$2"

ps -eo pid,comm,%cpu,%mem | tail -n +2 | while read -r line;
do 
    set -- $line
    if (( $(echo "$3 >= $cpu_threshold" | bc -l) ));
    then
        echo "WARNING: suspicious CPU usage: $2 (PID: $1)"
    fi
    if (( $(echo "$4 >= $mem_threshold" | bc -l) ));
    then
        echo "WARNING: suspicious MEM usage: $2 (PID: $1)"
    fi
done



