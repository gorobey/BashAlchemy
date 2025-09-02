#!/usr/bin/env bash
# Copy gnome-screencast.sh to /bin/gnome-screencast
# change shortcut in Settings > Keyboard > Shortcuts > Screenshots to gnome-screencast
# Run this script to open the screencast UI
# It will enable unsafe_mode, open the UI, then disable unsafe_mode
# Requires gdb to toggle unsafe_mode

set -euo pipefail

toggle_unsafe_with_gdb() {
  local val="$1" # true/false
  local pid
  pid="$(pidof gnome-shell || true)"
  if [[ -z "${pid}" ]]; then
    echo "[!] Non trovo il processo gnome-shell. Sei sicuro di essere in GNOME?"
    exit 1
  fi

  if ! command -v gdb >/dev/null 2>&1; then
    echo "[!] gdb non trovato. Installa gdb e riprova."
    exit 1
  fi

  local js="global.context.unsafe_mode = ${val}"
  echo "[i] Imposto unsafe_mode = ${val} nel processo gnome-shell (PID ${pid})"
  gdb -q -n -batch -p "${pid}" \
    -ex "call (void*) gjs_context_eval((void*)gjs_context_get_current(), \"${js}\", -1, \"\", 0, 0)" \
    -ex detach -ex quit >/dev/null 2>&1 || {
      echo "[!] Tentativo via gdb fallito."
      exit 1
    }
}

# Abilita unsafe_mode
toggle_unsafe_with_gdb true

# Se esiste il processo gjs legato a Screencast, killalo
gjs_pid=$(pgrep -f '/usr/bin/gjs /usr/share/gnome-shell/org.gnome.Shell.Screencast' || true)
if [ -n "$gjs_pid" ]; then
  kill -9 "$gjs_pid"
fi

# Lancia la UI di registrazione GNOME
gdbus call --session \
  --dest org.gnome.Shell \
  --object-path /org/gnome/Shell \
  --method org.gnome.Shell.Eval 'Main.screenshotUI.open();'

# Disabilita unsafe_mode
toggle_unsafe_with_gdb false