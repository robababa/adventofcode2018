#!/bin/bash

awk 'FNR > 2' input.txt | sed 's@=> @@g'
