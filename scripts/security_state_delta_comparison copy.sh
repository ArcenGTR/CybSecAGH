#!/bin/bash

./runtime_snapshot.sh
sleep 5
./runtime_snapshot.sh

files=($(ls -tr ../reports/runtime_snapshot_*.txt | tail -n 2))

if [ ${#files[@]} -lt 2 ]; then
    echo "Error: Insufficient snapshots found."
    exit 1
fi

file_old=${files[0]}
file_new=${files[1]}

top1=$(grep "Top CPU process:" "$file_old" | cut -d: -f2- | xargs)
top2=$(grep "Top CPU process:" "$file_new" | cut -d: -f2- | xargs)

unauth1=$(grep "Unauthorized processes:" "$file_old" | cut -d: -f2- | xargs)
unauth2=$(grep "Unauthorized processes:" "$file_new" | cut -d: -f2- | xargs)

class1=$(grep "Incident classification:" "$file_old" | cut -d: -f2- | xargs)
class2=$(grep "Incident classification:" "$file_new" | cut -d: -f2- | xargs)

echo "STATE CHANGE DETECTED:"

if [[ "$top1" == "$top2" ]]; then
    echo "Top CPU process changed: NO"
else
    echo "Top CPU process changed: YES"
fi

if [[ "$unauth1" == "$unauth2" ]]; then
    echo "Unauthorized process count changed: NO"
else
    echo "Unauthorized process count changed: YES ($unauth1 -> $unauth2)"
fi

if [[ "$class1" == "$class2" ]]; then
    echo "Incident classification changed: NO"
else
    echo "Incident classification changed: $class1 -> $class2"
fi