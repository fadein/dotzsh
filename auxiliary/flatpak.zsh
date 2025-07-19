if [[ -d /var/lib/flatpak/exports/share ]]; then
    path+=( /var/lib/flatpak/exports/share )
fi

if [[ -d $HOME/.local/share/flatpak/exports/share ]]; then
    path+=( $HOME/.local/share/flatpak/exports/share )
fi
