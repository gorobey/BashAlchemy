#!/usr/bin/env bash

## Funzione per ottenere l'utilizzo della CPU
getCpuUsage() {
  grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage ""}'
}

## Funzione per ottenere lo spazio su disco utilizzato
getDiskSpace() {
  local part=$1
  df -h | grep "$part" | awk '{ print $5 }' | cut -d'%' -f1
}