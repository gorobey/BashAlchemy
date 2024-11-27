#!/usr/bin/env bash

LOCK_FILE="$SCRIPT_DIR/${SCRIPT_NAME}.lock"

# Funzione per rimuovere il file di lock
cleanup() {
  if [ $? -eq 0 ]; then
    rm -f $LOCK_FILE
  fi
}

# Registra la funzione cleanup per essere eseguita all'uscita con successo
trap cleanup 0

# Funzione per rimuovere tutti i file di lock manualmente
clean_locks() {
  # Termina tutti i processi lanciati dallo script
  pkill -P $$
  # Rimuove tutti i file di lock
  echo $SCRIPT_DIR

  rm -f $SCRIPT_DIR/*.lock
  if [ $? -eq 0 ]; then
    log_message "info" "${SCRIPT_NAME} pronto per l'esecuzione."
  else
    log_message "error" "Errore durante la rimozione dei file di lock."
    exit 1
  fi
}

# Funzione per la creazione e la verifica del file di lock
lock_file() {
  # Controlla se il file di lock esiste
  if [ -f "$LOCK_FILE" ]; then
    log_message "warning" "Sembra che un'altra istanza di ${SCRIPT_NAME} sia già in esecuzione. PID: $$"
    exit 1
  else
    # Crea il file di lock
    echo $$ > $LOCK_FILE
  fi
}