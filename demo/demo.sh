#!/usr/bin/env bash 
# (wip...)

cp demo.zip .
cp config_demo.txt ../config.txt
./jautograde demo.zip
cp args?.txt ../input_args/
cp stdout*.txt ../expected/


