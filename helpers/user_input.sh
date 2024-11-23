#!/bin/bash

# Funzione per richiedere l'input dell'utente
get_user_input() {
  local prompt="$1"
  read -p "$prompt" user_input
  echo "$user_input"
}