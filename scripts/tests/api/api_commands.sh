#!/usr/bin/env bash
# Funzione per gestire le richieste API
handle_request() {
  local request=$1
  local response

  # Parse the JSON request
  command=$(echo "$request" | jq -r '.command')

  case "$command" in
    "get_time")
      response=$(date +%s)
      echo "{\"response\": \"$response\"}"
      ;;
    "get_date")
      response=$(date +%Y-%m-%d)
      echo "{\"response\": \"$response\"}"
      ;;
    "get_now_playing")
      response=$(bash ../audio/now_playing.sh)
      echo "$response"
      ;;
    *)
        echo '{"response": "Unknown command"}'
      ;;
  esac
}