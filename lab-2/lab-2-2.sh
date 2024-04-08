#!/bin/bash

set -eu

# czy podano argumenty
if [ ! $# -eq 2 ]
  then
    echo "Brak podanych 2 argumentow!"
    exit 1
fi

