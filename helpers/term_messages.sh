#!/usr/bin/env bash

info() {
  echo -e "\033[0;36m$1\033[0m"
}

warning() {
  echo -e "\033[0;33m$1\033[0m"
}

success() {
  echo -e "\033[0;32m$1\033[0m"
}

# Function to print text in red
error() {
  echo -e "\033[0;31m$1\033[0m"
}