#!/bin/bash

echo "Compiling Coffee"
cat coffee/*.coffee | coffee -s -o www/js/index.js > www/js/index.js 

echo "Executing 'cordova run'"
cordova run