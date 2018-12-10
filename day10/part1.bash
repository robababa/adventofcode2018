#!/bin/bash

for ((i=0; i<=10; i++))
do
    echo "time=${i}"
    psql --file=part1.sql advent
    sleep 4
    clear
done
