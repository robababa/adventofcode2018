#!/bin/bash

awk -F, '{print $1$2}' input.txt
