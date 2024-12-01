#!/usr/bin/env bash

# Usa zenity per selezionare la cartella della galleria immagini
gallery_path=$(zenity --file-selection --directory --title="Seleziona la cartella della galleria immagini")

# Verifica se una cartella è stata selezionata
if [ -z "$gallery_path" ]; then
  echo "Nessuna cartella selezionata."
  exit 1
fi

# Ottieni il nome della galleria
gallery_name=$(basename "$gallery_path")

# Inizializza una stringa JSON vuota
json_output="{}"

# Itera su ogni immagine nella cartella
for image_path in "$gallery_path"/*.{jpg,jpeg,png}; do
  # Verifica se il file esiste
  if [ ! -f "$image_path" ]; then
    continue
  fi

  # Apri l'immagine nel visualizzatore di immagini predefinito di GNOME
  xdg-open "$image_path"

  # Estrai i valori esistenti di DocumentName e ImageDescription
  document_name=$(exiftool -DocumentName -s3 "$image_path")
  image_description=$(exiftool -ImageDescription -s3 "$image_path")

  # Usa zenity per inserire DocumentName e ImageDescription
  form_data=$(zenity --forms --title="Inserisci i dettagli dell'immagine" \
    --text="Compila i campi seguenti:" \
    --add-entry="DocumentName" \
    --add-entry="ImageDescription")

  # Verifica se l'utente ha premuto "Annulla"
  if [ $? -ne 0 ]; then
    echo "Operazione annullata dall'utente."
    # Chiudi il visualizzatore di immagini se è aperto
    pkill eog
    exit 1
  fi

  # Verifica se i dati del form sono stati inseriti
  if [ -z "$form_data" ]; then
    echo "Nessun dato inserito per l'immagine $image_path."
    continue
  fi

  # Estrai i valori inseriti nel form
  document_name=$(echo "$form_data" | cut -d'|' -f1)
  image_description=$(echo "$form_data" | cut -d'|' -f2)

  # Verifica se entrambi i tag sono vuoti
  if [ -n "$document_name" ] || [ -n "$image_description" ]; then
    # Esegui il comando exiftool con i valori inseriti
    exiftool -overwrite_original -DocumentName="$document_name" -ImageDescription="$image_description" "$image_path"
  else
    echo "Entrambi i tag sono vuoti. Comando exiftool non eseguito."
  fi

  # Ottieni il nome del file immagine (senza il percorso completo)
  image_filename=$(basename "$image_path")

  # Aggiungi i dati dell'immagine al JSON
  json_output=$(echo "$json_output" | jq --arg filename "$image_filename" \
                                         --arg title "$document_name" \
                                         --arg description "$image_description" \
                                         '.[$filename] = {title: $title, description: $description}')

  # Chiudi il visualizzatore di immagini se è aperto
  pkill eog

done

# Crea il file JSON nella cartella della galleria
json_file="$gallery_path/${gallery_name}.json"
echo "$json_output" | jq '.' > "$json_file"

echo "Dati salvati in $json_file"