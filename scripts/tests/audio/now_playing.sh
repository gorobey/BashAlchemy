#!/bin/bash

# Check if required programs are installed
for cmd in socat jq; do
  if ! command -v $cmd &> /dev/null; then
    echo "$cmd is required but not installed. Please install it and try again."
    exit 1
  fi
done

# Check if mpv socket exists
if [ ! -S /tmp/mpvsocket ]; then
  echo "mpv socket not found at /tmp/mpvsocket. Ensure mpv is running with the correct socket path."
  exit 1
fi

# Function to get playback status from mpv
get_playback_status() {
  echo "Getting media-title..."
  media_title=$(echo '{ "command": ["get_property", "media-title"] }' | socat - /tmp/mpvsocket | jq -r '.data')
  echo "Media title: $media_title"

  echo "Getting metadata..."
  metadata=$(echo '{ "command": ["get_property", "metadata"] }' | socat - /tmp/mpvsocket | jq -r '.data')
  echo "Metadata: $metadata"

  echo "Getting icy-title..."
  icy_title=$(echo "$metadata" | jq -r '.["icy-title"]')
  echo "ICY title: $icy_title"

  echo "Getting duration..."
  duration=$(echo '{ "command": ["get_property", "duration"] }' | socat - /tmp/mpvsocket | jq -r '.data')
  echo "Duration: $duration"

  echo "Getting time-pos..."
  time_pos=$(echo '{ "command": ["get_property", "time-pos"] }' | socat - /tmp/mpvsocket | jq -r '.data')
  echo "Time position: $time_pos"

  echo "Getting time-remaining..."
  time_remaining=$(echo '{ "command": ["get_property", "time-remaining"] }' | socat - /tmp/mpvsocket | jq -r '.data')
  echo "Time remaining: $time_remaining"

  # Combine all information into a single JSON object
  jq -n --arg media_title "$media_title" --arg icy_title "$icy_title" --arg duration "$duration" --arg time_pos "$time_pos" --arg time_remaining "$time_remaining" \
    '{media_title: $media_title, icy_title: $icy_title, duration: $duration, time_pos: $time_pos, time_remaining: $time_remaining}'
}

# Display playback status
get_playback_status