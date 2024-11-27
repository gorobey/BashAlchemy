#!/usr/bin/env bash

# Directory degli helpers
HELPERS_DIR=$(dirname "$(realpath "$BASH_SOURCE")")
if [ -z "$HELPERS_DIR" ]; then
  echo "Errore: impossibile determinare la directory degli helpers."
  exit 1
fi

# Path dello script
SCRIPT_DIR=$(dirname "$(realpath "$0")")
if [ -z "$SCRIPT_DIR" ]; then
  echo "Errore: impossibile determinare la directory dello script."
  exit 1
fi

# Nome dello script
SCRIPT_NAME=$(basename "$0" .sh)
if [ -z "$SCRIPT_NAME" ]; then
  echo "Errore: impossibile determinare il nome dello script."
  exit 1
fi
