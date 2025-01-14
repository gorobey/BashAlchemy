#!/usr/bin/env bash

#echo -e "\e[1mbold\e[0m"
#echo -e "\e[3mitalic\e[0m"
#echo -e "\e[3m\e[1mbold italic\e[0m"
#echo -e "\e[4munderline\e[0m"
#echo -e "\e[9mstrikethrough\e[0m"

# Colori
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\e[0;36m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

LOG_FILE="$SCRIPT_DIR/${SCRIPT_NAME}.log"

# Funzione per loggare messaggi
log_message() {
    local type=$1
    local message=$2
    local color

    case $type in
        info)
            color=$CYAN
            ;;
        success)
            color=$GREEN
            ;;
        error)
            color=$RED
            ;;
        warning)
            color=$YELLOW
            ;;
        *)
            color=$NC
            ;;
    esac

    LOG_MSG="$(date '+%Y-%m-%d %H:%M:%S') - $HOSTNAME - $message"
    MSG="${color}$LOG_MSG${NC}"
    echo "$LOG_MSG" >> $LOG_FILE && echo -e $MSG
}