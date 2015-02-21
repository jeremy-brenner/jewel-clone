#!/bin/bash

echo "Compiling Coffee"
for c in coffee/*.coffee; do
  cat "${c}"  
  # echo a newline after each file 
  # so extra whitespace and the end dosn't end up at the start of a line on another
  echo 
done | coffee -s -o www/js/index.js > www/js/index.js 

