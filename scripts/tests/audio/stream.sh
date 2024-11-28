#!/usr/bin/env bash

# Import helpers
source "$HOME/Scripts/helpers/basedir.sh"
source "$HELPERS_DIR/logging.sh"
source "$HELPERS_DIR/term_messages.sh"
source "$HELPERS_DIR/lock_file.sh"

stream_mb="http://livex.radiopopolare.it:80/radiopop"
stream_zara="http://livex.radiopopolare.it:80/radiopop"
white_noise="$SCRIPT_DIR/white-noise.ogg"

# Function to get HTTP headers
get_headers() {
  local tcp_format
  tcp_format="/dev/tcp/$(echo "$1" | awk -F[/:] '{print $4}')/$(echo "$1" | awk -F[/:] '{print ($5 ? $5 : 80)}')"
  timeout 2 bash -c "<$tcp_format" && echo "200 OK" || echo "404 Not Found"
}

# Check the first stream
headers=$(get_headers "$stream_mb")
if echo "$headers" | grep -q "200 OK"; then
  url="$stream_mb"
else
  # Check the second stream
  headers=$(get_headers "$stream_zara")
  if echo "$headers" | grep -q "200 OK"; then
    url="$stream_zara"
  else
    url="$white_noise"
  fi
fi

# Create input configuration for mpv
cat <<EOL > input.conf
# Mouse controls
MBTN_LEFT cycle pause
MBTN_RIGHT quit
# Keyboard controls
SPACE cycle pause
q quit
UP add volume 5
DOWN add volume -5
s stop
EOL

ffprobe $url

# Play the audio stream with mpv and custom input configuration
mpv --input-ipc-server=/tmp/mpvsocket --input-conf=input.conf "$url"