#!/bin/bash

declare -A proc_whitelist
proc_whitelist=(
    ["gnome-shell"]=1
    ["bash"]=1
    ["sleep"]=1
    ["grep"]=1
    ["ps"]=1
    ["systemd"]=1
)

authorized=0
unauthorized=0

while read -r line;
do 
    set -- $line
    if [[ -n "${proc_whitelist[$2]}" ]];
    then
        ((authorized++))
        echo "AUTHORIZED PROCESS: $2 (PID: $1)"
    else
        ((unauthorized++))
        echo "UNAUTHORIZED PROCESS: $2 (PID: $1)"
    fi
done < <(ps -eo pid,comm | tail -n +2)

echo "TOTAL AUTHORIZED: $authorized"
echo "TOTAL UNAUTHORIZED: $unauthorized"


