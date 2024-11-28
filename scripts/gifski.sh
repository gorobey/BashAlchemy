#!/bin/bash

# Mostra una finestra iniziale con una casella di trascinamento file
video_file=$(zenity --title="Convertitore Video a GIF" --text="Trascina un file video nella casella sottostante" --entry --width=600 | tr -d '\r')

# Controlla se un file è stato selezionato
if [ -z "$video_file" ]; then
  zenity --error --text="Nessun file selezionato."
  exit 1
fi

# Controlla se il file esiste
if [ ! -f "$video_file" ]; then
  zenity --error --text="Il file selezionato non esiste."
  exit 1
fi

# Estrai il nome del file senza estensione
output_file="~/Video/gifs/$(basename "${video_file%.*}.gif")"

# Crea la cartella di destinazione se non esiste
mkdir -p $HOME/Video/gifs


# Mostra una finestra per gestire i parametri di gifski
fps=$(zenity --entry --title="Parametri gifski" --text="Inserisci il valore di FPS (frame per secondo):" --entry-text="10")
if [ -z "$fps" ]; then
  zenity --error --text="Nessun valore di FPS inserito."
  exit 1
fi

# Esegui gifski e mostra l'avanzamento in una finestra zenity
(
  gifski --fps "$fps" -o "$output_file" "$video_file" | while IFS= read -r line; do
    echo "# $line"
  done
) | zenity --progress --title="Conversione in corso" --text="Conversione del video in GIF..." --percentage=0 --auto-close

# Controlla se la conversione è riuscita
if [ $? -eq 0 ]; then
  zenity --info --text="Conversione completata con successo! File salvato come $output_file"
  # Apri la cartella contenente il file GIF
  xdg-open "$(dirname "$output_file")"
else
  zenity --error --text="Errore durante la conversione del video."
fi