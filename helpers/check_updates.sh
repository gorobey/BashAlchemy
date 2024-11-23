#!/usr/bin/env bash

check_updates() {
  # Aggiorna TT-SyncManager
  cd $SCRIPT_DIR || { log_message "error" "Errore qualquadra non cosa"; exit 1; }

  # Verifica se ci sono aggiornamenti disponibili
  git fetch origin > /dev/null 2>&1
  UPDATES=$(git status -uno 2>/dev/null | grep 'Your branch is behind')

  if [ -n "$UPDATES" ]; then
    log_message "warning" "Sono presenti aggiornamenti, esegui '$SCRIPT_DIR/ttsyncmanager update'"
    cleanup
  else
    log_message "info" "TT-SyncManager è aggiornato"
    cleanup
  fi
}

pull_updates() {
  # Navigate to the script directory
  cd $SCRIPT_DIR || { log_message "error" "Errore qualquadra non cosa"; exit 1; }

  # Perform git pull to fetch updates
  CMD=$(git pull origin master 2>&1)
  if [ $? -eq 0 ]; then
    log_message "success" "TT-SyncManager aggiorrnato con successo"
    cleanup
  else
    log_message "error" "Errore durante git pull:\n\r$CMD"
    exit 1
  fi
}
