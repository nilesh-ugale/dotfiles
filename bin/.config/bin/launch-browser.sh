#!/usr/bin/env bash

default_browser=$(xdg-settings get default-web-browser)
desktop_file=$(ls {~/.local,~/.nix-profile,/usr}/share/applications/$default_browser 2>/dev/null | head -1)
browser_exec=$(sed -n 's/^Exec=\([^ ]*\).*/\1/p' "$desktop_file" | head -1)
browser_class=$(sed -n 's/^StartupWMClass=//p' "$desktop_file" | head -1)

# Print the address of the first browser window that is private (1) or
# normal (0). Private windows always start on "New Private Tab".
find_window() {
  hyprctl clients | awk -v cls="$browser_class" -v want="$1" '
    /^Window /         { addr = $2 }
    /^\tclass:/        { class = $2 }
    /^\tinitialTitle:/ { private = /^\tinitialTitle: New Private Tab/
                         if (class == cls && private == want) { print addr; exit } }'
}

# Focus an open window of the same kind instead of opening a new one
[[ $* == *--private* ]] && want_private=1 || want_private=0
if [[ -n $browser_class ]]; then
  addr=$(find_window $want_private)
  [[ -n $addr ]] && exec hyprctl dispatch "hl.dsp.focus({ window = \"address:0x$addr\" })"
fi

if [[ $browser_exec =~ (firefox|zen|librewolf|mullvad) ]]; then
  private_flag="--private-window"
elif [[ $browser_exec =~ edge ]]; then
  private_flag="--inprivate"
else
  private_flag="--incognito"
fi

exec "$browser_exec" "${@/--private/$private_flag}"

