#!/usr/bin/env bash

# Import helpers
source "basedir.sh"
source "$HELPERS_DIR/logging.sh"
source "$HELPERS_DIR/lock_file.sh"

check_updates() {
  # vai alla cartella dello script
  cd $SCRIPT_DIR || { log_message "error" "Errore qualquadra non cosa"; exit 1; }

  # Verifica se ci sono aggiornamenti disponibili
  git fetch origin > /dev/null 2>&1
  UPDATES=$(git status -uno 2>/dev/null | grep 'Your branch is behind')

  if [ -n "$UPDATES" ]; then
    log_message "warning" "Sono presenti aggiornamenti, esegui '$0 update'"
    cleanup
  else
    log_message "info" "$0 è aggiornato"
    cleanup
  fi
}

pull_updates() {
  # Navigate to the script directory
  cd $SCRIPT_DIR || { log_message "error" "Errore qualquadra non cosa"; exit 1; }

  # Perform git pull to fetch updates
  CMD=$(git pull origin master 2>&1)
  if [ $? -eq 0 ]; then
    log_message "success" "$0 aggiorrnato con successo"
    cleanup
  else
    log_message "error" "Errore durante git pull:\n\r$CMD"
    exit 1
  fi
}

# Controlla i parametri passati allo script
case "$1" in
  check)
    check_updates
    ;;
  update)
    pull_updates
    ;;
esac
