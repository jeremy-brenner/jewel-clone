#!/bin/bash

. scripts/build_coffee.sh

echo "Executing 'cordova build'"
cordova build --release
