#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Info:
#   author:    Miroslav Vidovic
#   file:      spinner.sh
#   created:   27.08.2016.-12:10:47
#   revision:  19.09.2017.
#   modified:  16.11.2024 by Giulio Gorobey
#   version:   1.2
# -----------------------------------------------------------------------------
# Description:
#   Show the spinner animation while executing some long command
# Usage:
#   source spinner.sh
#   run_with_spinner <command>
# -----------------------------------------------------------------------------
# Script:

show_spinner() {
  # ID of the process the executing while the spinner is showing
  local -r pid="${1}"
  # Delay for the spinner animation
  local -r delay='0.2'
  # Lines forming the spinner
  local spinstr='|/-\'
  # Empty variable
  local temp
  # Disable the cursor for better animation
  tput civis

  # Show the animation while the process is running
  while kill -0 "$pid" 2>/dev/null; do
    temp="${spinstr#?}"
    printf " [%c]  " "${spinstr}"
    spinstr=${temp}${spinstr%"${temp}"}
    sleep "${delay}"
    printf "\b\b\b\b\b\b"
  done
}

# Trap the exit signal and enable cursor
signal() {
  echo -e "\n\nExiting on trapped signal...\n"
  tput cnorm
  exit 1
}

trap signal 1 2 3 15

# Function to print text in green
success() {
  echo -e "\033[0;32m$1\033[0m"
}

# Function to print text in red
error() {
  echo -e "\033[0;31m$1\033[0m"
}

# Funzione per eseguire qualsiasi comando e catturare output ed errori
exec() {
  local cmd=("$@")
  local output_file="/tmp/output_log"
  local error_file="/tmp/error_log"

  # Esegui il comando e cattura sia l'output che l'errore in file separati
  "${cmd[@]}" >"$output_file" 2>"$error_file"
  local exit_status=$?

  # Rimuovi i byte nulli dall'output e dagli errori
  tr -d '\0' <"$output_file" >"${output_file}_clean"
  tr -d '\0' <"$error_file" >"${error_file}_clean"

  # Se il comando fallisce, restituisci l'errore
  if [ $exit_status -ne 0 ]; then
    cat "${error_file}_clean" >&2
    return 1
  fi
  return 0
}


run_with_spinner() {
  local cmd=("$@")
  local output_file="/tmp/output_log"
  local error_file="/tmp/error_log"
  local output
  local error_output

  # Esegui il comando in background e cattura l'output
  { "${cmd[@]}" >"$output_file" 2>"$error_file"; } &
  show_spinner "$!"
  wait "$!"
  local exit_status=$?

  # Rimuovi i byte nulli dall'output e dagli errori
  tr -d '\0' <"$output_file" >"${output_file}_clean"
  tr -d '\0' <"$error_file" >"${error_file}_clean"

  # Leggi l'output dai file puliti
  output=$(cat "${output_file}_clean")
  error_output=$(cat "${error_file}_clean")

  if [ $exit_status -eq 0 ]; then
    if [ -n "$output" ]; then
      echo -e "\r [$(success '*')]  $output"
    else
      echo -e "\r [$(success '*')]"
    fi
  else
    echo -e "\r [$(error '*')]  $error_output"
  fi

  # Abilita di nuovo il cursore
  tput cnorm
  return $exit_status
}