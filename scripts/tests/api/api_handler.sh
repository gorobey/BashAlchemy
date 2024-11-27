#!/bin/bash

#usage: echo '{"command": "get_now_playing"}' | socat - TCP:localhost:12345

# Import logging helper
source ../../../helpers/logging.sh

# Leggi la richiesta dalla connessione socket
read request

# Gestisci la richiesta e invia la risposta
response=$(./api_server.sh handle_request "$request")
echo "$response"