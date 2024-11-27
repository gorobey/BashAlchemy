#!/bin/bash

#Download music from here:
#https://emp3juice.la/

uri="Linkin Park_ The Emptiness Machine The Tonight Show Starring Jimmy Fallon.mp3"
# Play the audio stream with mpv and custom input configuration
mpv --input-ipc-server=/tmp/mpvsocket --input-conf=input.conf "$uri"