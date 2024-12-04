#!/usr/bin/env bash

# Directory degli helpers
HELPERS_DIR=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
if [ -z "$HELPERS_DIR" ]; then
  echo "Error: $HELPERS_DIR not found."
  exit 1
fi

# Path dello script
SCRIPT_DIR=$(dirname "$(realpath "$0")")
if [ -z "$SCRIPT_DIR" ]; then
  echo "Error: $SCRIPT_DIR not found."
  exit 1
fi

# Nome dello script
SCRIPT_NAME=$(basename "$0" .sh)
if [ -z "$SCRIPT_NAME" ]; then
  echo "Error: $SCRIPT_NAME not found."
  exit 1
fi
