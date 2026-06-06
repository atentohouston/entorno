#!/bin/bash

# Obtener carpeta de descargas y escritorio
DOWNLOADS=$(grep "^XDG_DOWNLOAD_DIR" "$HOME/.config/user-dirs.dirs" | cut -d '"' -f2)
DESKTOP=$(grep "^XDG_DESKTOP_DIR" "$HOME/.config/user-dirs.dirs" | cut -d '"' -f2)

sudo chown root:root /usr/local/share/zsh/site-functions/_bspc


# Expandir $HOME si aparece en la ruta
DOWNLOADS="${DOWNLOADS/\$HOME/$HOME}"
DESKTOP="${DESKTOP/\$HOME/$HOME}"

# Copiar p10k.zsh para usuario normal y root
echo "[*] Configurando p10k.zsh..."

cp "$DOWNLOADS/entorno/p10k.zsh" "$HOME/.p10k.zsh"
sudo cp "$DOWNLOADS/entorno/p10k.zsh" /root/.p10k.zsh

echo "[+] p10k.zsh configurado para $USER y root"

sudo ln -sf "$HOME/.zshrc" /root/.zshrc

# Dar permisos de ejecución a los scripts
echo "[*] Configurando permisos..."

chmod 775 "$HOME/.config/bspwm/bspwmrc"
chmod 664 "$HOME/.config/sxhkd/sxhkdrc"
chmod 775 "$HOME/.config/scripts/"*
chmod 775 "$HOME/.config/polybar/launch.sh"
chmod +x "$HOME/.config/polybar/scripts/powermenu"
chmod +x "$HOME/.config/polybar/scripts/powermenu_alt"

echo "[+] Permisos configurados"
