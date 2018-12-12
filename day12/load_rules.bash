#!/bin/bash

awk 'FNR > 2' sample_input.txt | sed 's@=> @@g'
