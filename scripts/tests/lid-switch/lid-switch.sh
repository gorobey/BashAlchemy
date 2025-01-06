#!/bin/bash
# Lid switch script
# This script monitors the state of the lid and turns off the screen when the lid is closed.
# It also turns on the screen when the lid is opened.
# The script is intended to be used on a laptop without X11.
# The script uses ACPI to monitor the state of the lid.
# The script is intended to be used with systemd to run as a service.
# The script requires root privileges to access the ACPI files.


#####################################
# HOW TO INSTALL LID SWITCH
#####################################
# place the script in /usr/local/bin/lid-switch.sh
# make it executable with chmod +x /usr/local/bin/lid-switch.sh
# copy lid-switch.service in /etc/systemd/system/lid-switch.service
# reload systemd with systemctl daemon-reload
# enable the service with systemctl enable lid-switch.service
# start the service with systemctl start lid-switch.service


# Path to the display device and the ACPI device for the lid switch.
# card1-eDP-1 is the display device on the laptop.
# LID0 is the ACPI device for the lid switch.
# check the correct path on your system.
# Search the correct display path in /sys/class/drm/
# Search the correct ACPI path in /proc/acpi/button/lid/

DISPLAY="/sys/class/drm/card1-eDP-1/status"
ACPI="/proc/acpi/button/lid/LID0/state"

# Funzione per spegnere lo schermo (senza X11)
spegnere_schermo() {
    # Se il dispositivo di display è presente, spegni lo schermo
    if [[ -d "/sys/class/drm/card1-eDP-1" ]]; then
        echo "off" | sudo tee $DISPLAY
        echo "screen OFF"

        # Arresta la sessione grafica
        sudo systemctl stop display-manager.service

        # Termina Xorg
        sudo pkill Xorg

        # Termina la sessione GNOME
        gnome-session-quit --force --no-prompt


    else
        echo "Errore: display non trovato"
    fi
}

# Funzione per accendere lo schermo (senza X11)
accendere_schermo() {
    # Se il dispositivo di display è presente, riaccendi lo schermo
    if [[ -d "/sys/class/drm/card1-eDP-1" ]]; then
        echo "on" | sudo tee $DISPLAY
        echo "screen ON"

        # Restart the graphical session
        sudo systemctl start display-manager.service
    else
        echo "Errore: display non trovato"
    fi
}

# Funzione per verificare lo stato del coperchio
check_lid_state() {
    local lid_state
    if [[ -f $ACPI ]]; then
        lid_state=$(cat $ACPI | awk '{ print $2 }')
        echo "$lid_state"
    else
        echo "File $ACPI non trovato. Verifica il supporto ACPI."
    fi
}

# Funzione principale per monitorare lo stato del coperchio
main() {
    local last_lid_state=""
    # Ciclo infinito per monitorare lo stato del coperchio
    while true; do
            lid_state=$(check_lid_state)
            echo "lid_state $lid_state last_lid_state $last_lid_state"
            if [[ "$lid_state" != "$last_lid_state" ]]; then
                case "$lid_state" in
                    open)
                        accendere_schermo
                        ;;
                    closed)
                        spegnere_schermo
                        ;;
                    *)
                        echo "Stato coperchio sconosciuto: $lid_state"
                        ;;
                esac
                last_lid_state="$lid_state"
            fi

        # Pausa di 2 secondi per evitare un controllo troppo frequente
        sleep 2
    done
}

# Esegui la logica principale
main
