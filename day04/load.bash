#!/usr/bin/env bash
sed 's/\[//g; s/\]//g ; s/falls //g; s/ up//g; s/ begins shift//g; s/#//g' ./input.txt | awk '{if ($4=="") $4="null"; print $1"T"$2" "$3" "$4}'
