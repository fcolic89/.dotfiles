#!/usr/bin/env bash

if [ $(command -v "free") ]; then
  echo "[r:$(free -w | awk 'FNR == 2 {sum=$3*100/$2} END {print substr(sum, 0, 2)"%"}')]"
fi
