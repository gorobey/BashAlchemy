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