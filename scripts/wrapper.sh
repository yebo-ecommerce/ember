#!/bin/bash

# Get configs and functions
source scripts/run.sh

before_script

if [ -f "scripts/$1.sh" ]; then
  echo "-----> Runnig scripts/$1.sh"
  scripts/$1.sh
else
  echo "-----> Runnig inside container: $@"
  $@
fi

after_script

