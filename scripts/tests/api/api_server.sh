#!/usr/bin/env bash
#config
PORT=8083

# Import helpers
source "/home/goro/Scripts/helpers/basedir.sh"
source "$HELPERS_DIR/logging.sh"
source "$HELPERS_DIR/term_messages.sh"
source "$HELPERS_DIR/lock_file.sh"

status_server() {
  if lsof -i:$PORT > /dev/null; then
    info "API server is running on port $PORT"
  else
    warning "API server is not running"
  fi
  tail -n 10 $LOG_FILE
  exit 1
}

stop_server() {
  log_message "info" "Stopping server API"
  fuser -k $PORT/tcp
  cleanup
  pkill -f "$(basename "$0")"
}

start_server() {
  lock_file
  while true; do
    if ! lsof -i:$PORT > /dev/null; then
      log_message "success" "API server listening on the port $PORT"
      socat TCP-LISTEN:$PORT,fork EXEC:./api_handler.sh
    else
      status_server
      exit 0
    fi
    sleep 1
    if [[ "$(tail -n 1 "$LOG_FILE")" == *"Stopping server API"* ]]; then
      log_message "error" "Server crashed with exit code $?. Restarting..."
    fi
  done
}

# Controlla i parametri passati allo script
case "$1" in
  stop)
    stop_server
    ;;
  status)
    status_server
    ;;
  start)
    start_server &
    ;;
esac

trap cleanup EXIT

source "$SCRIPT_DIR/api_commands.sh"

# Check if the script was called with an argument
if [ "$1" == "handle_request" ]; then
  handle_request "$2"
fi