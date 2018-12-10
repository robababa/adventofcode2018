#!/bin/bash

sed 's@position=@@g; s@velocity=@@g; s@,@@g; s@< @@g; s@<@@g; s@>@@g; s@  @ @g' input.txt
