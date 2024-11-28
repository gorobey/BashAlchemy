#!/bin/bash

# Check if required programs are installed
for cmd in socat jq; do
  if ! command -v $cmd &> /dev/null; then
    echo "{\"response\": \"$cmd is required but not installed. Please install it and try again.\"}"
    exit 1
  fi
done

# Check if mpv socket exists
if [ ! -S /tmp/mpvsocket ]; then
  echo "{\"response\": \"mpv socket not found at /tmp/mpvsocket. Ensure mpv is running with the correct socket path.\"}"
  exit 1
fi

get_playback_status() {
# Function to get playback status from mpv
media_title=$(echo '{ "command": ["get_property", "media-title"] }' | socat - /tmp/mpvsocket | jq -r '.data')
  metadata=$(echo '{ "command": ["get_property", "metadata"] }' | socat - /tmp/mpvsocket | jq -r '.data')
  icy_title=$(echo "$metadata" | jq -r '.["icy-title"]')
  duration=$(echo '{ "command": ["get_property", "duration"] }' | socat - /tmp/mpvsocket | jq -r '.data')
  time_pos=$(echo '{ "command": ["get_property", "time-pos"] }' | socat - /tmp/mpvsocket | jq -r '.data')
  time_remaining=$(echo '{ "command": ["get_property", "time-remaining"] }' | socat - /tmp/mpvsocket | jq -r '.data')

  # Combine all information into a single JSON object
  response=$(jq -n --arg media_title "$media_title" --arg icy_title "$icy_title" --arg duration "$duration" --arg time_pos "$time_pos" --arg time_remaining "$time_remaining" \
    '{media_title: $media_title, icy_title: $icy_title, duration: $duration, time_pos: $time_pos, time_remaining: $time_remaining}')
  echo "$response"
}
# Display playback status
get_playback_status