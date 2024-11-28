#!/usr/bin/env bash

stream_mb="https://nr14.newradio.it:8631/stream?ext=.mp3?$(shuf -i 1-100000 -n 1)"
stream_zara="http://streaming.radiofragola.com:8000/test.ogg?$(shuf -i 1-100000 -n 1)"
white_noise="https://radioincorso.it/assets/audio/white-noise.ogg"

# Function to get HTTP headers
get_headers() {
  local tcp_format="/dev/tcp/$(echo "$1" | awk -F[/:] '{print $4}')/$(echo "$1" | awk -F[/:] '{print ($5 ? $5 : 80)}')"
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

# Play the audio stream with mpv and custom input configuration
mpv --input-ipc-server=/tmp/mpvsocket --input-conf=input.conf "$url"