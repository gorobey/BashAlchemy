#!/bin/bash
#config
PORT=8083

# Import helpers
source "../../../helpers/basedir.sh"
source "$HELPERS_DIR/logging.sh"
source "$HELPERS_DIR/lock_file.sh"

kill_existing_instances() {
  log_message "info" "Killing existing instances of the serve API"
  fuser -k $PORT/tcp
  cleanup
  pkill -f "$(basename "$0")"
}

# Controlla i parametri passati allo script
case "$1" in
  kill)
    kill_existing_instances
    ;;
esac

trap cleanup EXIT

# Funzione per gestire le richieste API
handle_request() {
  local request=$1
  local response

  # Parse the JSON request
  command=$(echo "$request" | jq -r '.command')

  case "$command" in
    "get_time")
      response=$(date +%s)
      ;;
    "get_date")
      response=$(date +%Y-%m-%d)
      ;;
    "echo")
      message=$(echo "$request" | jq -r '.message')
      response="$message"
      ;;
    "get_now_playing")
      response=$(bash ../audio/now_playing.sh)
      ;;
    *)
      response="Unknown command"
      ;;
  esac

  # Return the response as JSON
  echo "{\"response\": \"$response\"}"
}

# Check if the script was called with an argument
if [ "$1" == "handle_request" ]; then
  handle_request "$2"
else
    lock_file
    log_message "info" "Starting API server..."
  # Loop to restart the server in case of an error
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
fi
