#!/bin/bash
#config
PORT=8083

# Import helpers
source "/home/goro/Scripts/helpers/basedir.sh"
source "$HELPERS_DIR/logging.sh"
source "$HELPERS_DIR/lock_file.sh"

status_server() {
  if lsof -i:$PORT > /dev/null; then
    log_message "info" "API server is running on port $PORT"
  else
    log_message "info" "API server is not running"
  fi
  exit 1
}

kill_server() {
  log_message "info" "Killing existing instances of the serve API"
  fuser -k $PORT/tcp
  cleanup
  pkill -f "$(basename "$0")"
}

start_server() {
  lock_file
  log_message "info" "Starting API server..."
  while true; do
    log_message "info" "Checking if API server is already running..."
    if ! lsof -i:$PORT > /dev/null; then
      log_message "success" "API server run..."
      socat TCP-LISTEN:$PORT,fork EXEC:./api_handler.sh
    else
      log_message "info" "API server is already running on port $PORT. Exiting..."
      exit 0
    fi
    log_message "error" "Server crashed with exit code $?. Restarting..."
    sleep 1
  done
}

# Controlla i parametri passati allo script
case "$1" in
  kill)
    kill_server
    ;;
  status)
    status_server
    ;;
  start)
    start_server
    ;;
esac

trap cleanup EXIT

source api_commands.sh

# Check if the script was called with an argument
if [ "$1" == "handle_request" ]; then
  handle_request "$2"
fi