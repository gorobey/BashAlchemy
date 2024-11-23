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
  # Rimuove tutti i file di lock
  rm -f $SCRIPT_DIR/*.lock
  if [ $? -eq 0 ]; then
    log_message "info" "TT-SyncManager pronto per l'esecuzione."
  else
    log_message "error" "Errore durante la rimozione dei file di lock."
    exit 1
  fi
}

# Funzione per la creazione e la verifica del file di lock
lock_file() {
  # Controlla se il file di lock esiste
  if [ -f "$LOCK_FILE" ]; then
    log_message "warning" "Esecuzione inibita, possibili cause:\n\r
    1. un'altra istanza dello script è già in esecuzione.\n\r
    2. l'ultima esecuzione dello script non è terminata correttamente.\n\r
    -------------------\n\r
    Per dettagli verifica il file di log:\n\r
    $SCRIPT_DIR/ttsyncmanager.log\n\r
    Per rimuovi il file di lock riesegui il comando usando l'opzione [clean]."

    exit 1
  else
    # Crea il file di lock
    touch $LOCK_FILE
  fi
}
