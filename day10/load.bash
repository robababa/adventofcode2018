#!/bin/bash

sed 's@position=@@g; s@velocity=@@g; s@,@@g; s@< @@g; s@<@@g; s@>@@g; s@  @ @g' sample_input.txt
