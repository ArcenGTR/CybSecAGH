#!/bin/bash

e1=0
e2=0

cat ../sat-001.log | while read -r line; do
    [[ "$line" == *"ERROR"* ]] && ((e1++))
    echo "$e1" > .e1
done

cat ../sat-002.log | while read -r line; do
    [[ "$line" == *"ERROR"* ]] && ((e2++))
    echo "$e2" > .e2
done

read v1 < .e1
read v2 < .e2

if [ $v1 -gt $v2 ]; then
    echo "sat-001"
else
    echo "sat-002"
fi

rm .e1 .e2
