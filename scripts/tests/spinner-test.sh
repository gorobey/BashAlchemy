#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Info:
#   file:      spinner-test.sh
#   created:   16.11.2024
# -----------------------------------------------------------------------------
# Description:
#   Test the functionality of spinner.sh
# -----------------------------------------------------------------------------
# Script:

# Source the spinner.sh script
source ../../helpers/spinner.sh

# Funzione di test (successo)
long_running_command_success() {
  echo "Starting a long-running command (success)..."
  sleep 1
  # Usa exec_mcd per catturare e stampare l'output
  exec_mcd echo "Long-running command completed successfully"
}

# Funzione di test (errore)
long_running_command_error() {
  echo "Starting a long-running command (error)..."
  sleep 2
  exec_mcd cp /path/to/nonexistent/file /path/to/destination/
}

# Run the long-running commands with the spinner
run_with_spinner long_running_command_success
run_with_spinner long_running_command_error
run_with_spinner long_running_command_success
run_with_spinner long_running_command_error
