#!/bin/bash
# Goяo! remote backup rotation solution:

#esegui come root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# Path dello script
SCRIPT_DIR=$(dirname "$(realpath "$0")")
# Nome del file di lock dinamico
SCRIPT_NAME=$(basename "$0" .sh)
# Hostname
HOSTNAME=$(hostname)

TODAY=$(date +%Y-%m-%d)
SERVER="127.0.0.1"
PORT="2049"
REMOTE_DIR="/srv/nfs"
LOCAL_DIR="/mnt/nfs"

#import helpers
source "../../helpers/logging.sh"
source "../../helpers/term_messages.sh"
source "../../helpers/spinner.sh"
source "../../helpers/lock_file.sh"
source "../../helpers/network.sh"

#tenta il montaggio del disco remoto
mountpoint() {
  # tenta il montaggio del disco remoto fino a 3 volte in caso di errore
  for i in {1..3}; do
    if grep -qs $LOCAL_DIR /proc/mounts; then
      success "Disco remoto già montato."
      exit 0
    fi
    # pinga il server
    CMD=$(check_remote_server $SERVER $PORT 2>&1)
    # se check_remote_server ritorna 3, il server è raggiungibile
    if [ $? -eq 3 ]; then
      # se il disco è già montato esci dal ciclo
      CMD=$(mount -t nfs -o port=$PORT $SERVER:$REMOTE_DIR/backups $LOCAL_DIR/ 2>&1)
      if [[ $CMD == *"mount point $LOCAL_DIR does not exist"* ]]; then
        log_message "error" "Errore: il mount point $LOCAL_DIR non esiste."
      elif [[ $CMD == *"Failed to resolve server $SERVER: Name or service not known"* ]]; then
        log_message "error" "Errore: servizio sconosciuto."
      else
        success "Disco remoto pronto all'uso."
        #esci dal ciclo
        return 0
      fi
      warning "Tentativo di montaggio fallito, riprovo..."
    fi
    # attende 10 secondi prima di ritentare
    sleep 10
  done
  log_message "error" "Montaggio fallito dopo 3 tentativi."
  exit 1
}

clean() {
	run_with_spinner echo "clean";
	run_with_spinner find /mnt/nfs/backups/others/ -type f -not -newermt $(date -d "-30 day" +%Y-%m-%d) -name \"*.tar\" -delete
}

backup() {
	run_with_spinner echo "backup";
	run_with_spinner rsync -c --progress --ignore-existing /backup/*.$TODAY*.tar /mnt/nfs/backups/others/
}

if mountpoint; then
		clean;
		backup;
fi
