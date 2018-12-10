#!/bin/bash

psql --file=load.sql advent

psql --file=part1.sql advent

psql --command='select moves from day10_moves' advent
