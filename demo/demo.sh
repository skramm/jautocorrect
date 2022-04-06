#!/usr/bin/env bash 
# (wip...)

# prepare environment
mkdir -p tmp/exec
mkdir -p tmp/expected
mkdir -p tmp/input_args
mkdir -p tmp/src

cp jautograde.sh tmp/

cd demo
zip --quiet demo.zip *.java
cp demo.zip ../tmp/
cp config_demo.txt ../tmp/config.txt
cp args?.txt ../tmp/input_args/
cp stdout*.txt ../tmp/expected/

# run program with demo stuff
cd ../tmp/
./jautograde.sh demo.zip


