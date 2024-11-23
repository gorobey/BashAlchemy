#!/bin/bash

# Funzione per convertire HEX a RGB
hex_to_rgb() {
  hex=$1
  # Aggiungi il carattere # se manca
  if [[ $hex != \#* ]]; then
    hex="#$hex"
  fi
  if [[ ${#hex} -eq 7 ]]; then
    r=$(printf "%d" 0x${hex:1:2})
    g=$(printf "%d" 0x${hex:3:2})
    b=$(printf "%d" 0x${hex:5:2})
    echo "RGB: $r, $g, $b"
  elif [[ ${#hex} -eq 9 ]]; then
    r=$(printf "%d" 0x${hex:1:2})
    g=$(printf "%d" 0x${hex:3:2})
    b=$(printf "%d" 0x${hex:5:2})
    a=$(printf "%d" 0x${hex:7:2})
    echo "RGBA: $r, $g, $b, $a"
  else
    echo "Formato HEX non valido"
  fi
}

# Funzione per convertire RGB a HEX
rgb_to_hex() {
  r=$1
  g=$2
  b=$3
  if [[ -z $4 ]]; then
    printf "#%02x%02x%02x\n" $r $g $b
  else
    a=$4
    printf "#%02x%02x%02x%02x\n" $r $g $b $a
  fi
}

# Menu di selezione con zenity
choice=$(zenity --list --title="Convertitore Colori" --column="Operazione" "HEX a RGB" "RGB a HEX" "Seleziona Colore")

if [[ $choice == "HEX a RGB" ]]; then
  hex=$(zenity --entry --title="HEX a RGB" --text="Inserisci il valore HEX (es. #RRGGBB o #RRGGBBAA):")
  result=$(hex_to_rgb $hex)
  zenity --info --title="Risultato" --text="$result"
elif [[ $choice == "RGB a HEX" ]]; then
  rgb_input=$(zenity --entry --title="RGB a HEX" --text="Inserisci i valori RGB(A) (es. rgb(255,255,255) o rgba(255,255,255,1)):")
  rgb_input=$(echo $rgb_input | tr -d ' ' | sed -E 's/rgba?\(([^)]+)\)/\1/')
  IFS="," read -r r g b a <<< "$rgb_input"
  result=$(rgb_to_hex $r $g $b $a)
  zenity --info --title="Risultato" --text="$result"
elif [[ $choice == "Seleziona Colore" ]]; then
  color=$(zenity --color-selection --title="Seleziona Colore")
  rgb_result=$(hex_to_rgb $color)
  result="HEX: $color\n$rgb_result"
  zenity --info --title="Risultato" --text="$result"
else
  zenity --error --title="Errore" --text="Operazione non valida"
fi