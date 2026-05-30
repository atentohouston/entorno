#!/bin/bash

# Verificar que NO se ejecute como root
if [ "$EUID" -eq 0 ]; then
    echo "[-] No ejecutes el script como root, usa tu usuario normal"
    exit 1
fi

# Instalar dependencias
echo "[*] Instalando dependencias de bspwm y sxhkd..."
sudo apt install -y build-essential git vim \
    libxcb1-dev libxcb-util0-dev libxcb-ewmh-dev \
    libxcb-randr0-dev libxcb-icccm4-dev libxcb-keysyms1-dev \
    libxcb-xinerama0-dev libxcb-xkb-dev libasound2-dev \
    libxcb-xtest0-dev libxcb-shape0-dev
echo "[+] Dependencias instaladas"

# Actualizar sistema
echo "[*] Actualizando sistema..."
sudo apt update -y
echo "[+] Sistema actualizado"

# Obtener carpeta de descargas sin importar el idioma
DOWNLOADS=$(xdg-user-dirs-query DOWNLOAD)
# Obtener carpeta de escritorio
DESKTOP=$(xdg-user-dirs-query DESKTOP)

# Clonar repositorios
echo "[*] Clonando bspwm y sxhkd..."
cd "$DOWNLOADS"
git clone https://github.com/baskerville/bspwm.git
git clone https://github.com/baskerville/sxhkd.git
echo "[+] Repositorios clonados"

# Compilar e instalar bspwm
echo "[*] Compilando e instalando bspwm..."
cd "$DOWNLOADS/bspwm"
make
sudo make install
echo "[+] bspwm instalado"

# Compilar e instalar sxhkd
echo "[*] Compilando e instalando sxhkd..."
cd "$DOWNLOADS/sxhkd"
make
sudo make install
echo "[+] sxhkd instalado"

# Clonar repo de configuraciones
echo "[*] Clonando repositorio de configuraciones..."
cd "$DOWNLOADS"
git clone https://github.com/atentohouston/entorno.git
echo "[+] Repositorio clonado"

# Mover configuraciones a ~/.config
echo "[*] Moviendo configuraciones a ~/.config..."
for dir in bspwm kitty nvim picom polybar rofi scripts sxhkd bin; do
    if [ -d "$DOWNLOADS/entorno/$dir" ]; then
        mv "$DOWNLOADS/entorno/$dir" "$HOME/.config/"
        echo "[+] $dir movido a ~/.config"
    else
        echo "[-] No se encontró $dir en el repositorio"
    fi
done

# Obtener carpeta de escritorio sin importar el idioma

# Mover Fondos al escritorio
echo "[*] Moviendo Fondos al escritorio..."
if [ -d "$DOWNLOADS/entorno/Fondos" ]; then
    mv "$DOWNLOADS/entorno/Fondos" "$DESKTOP/"
    echo "[+] Fondos movido a $DESKTOP"
else
    echo "[-] No se encontró la carpeta Fondos en el repositorio"
fi

# Instalar polybar
echo "[*] Instalando polybar..."
sudo apt install -y polybar
echo "[+] Polybar instalada"

# Instalar dependencias de picom
echo "[*] Instalando dependencias de picom..."
sudo apt install -y libconfig-dev libdbus-1-dev libegl-dev libev-dev libgl-dev \
    libepoxy-dev libpcre2-dev libpixman-1-dev libx11-xcb-dev libxcb1-dev \
    libxcb-composite0-dev libxcb-damage0-dev libxcb-glx0-dev libxcb-image0-dev \
    libxcb-present-dev libxcb-randr0-dev libxcb-render0-dev libxcb-render-util0-dev \
    libxcb-shape0-dev libxcb-util-dev libxcb-xfixes0-dev meson ninja-build uthash-dev
echo "[+] Dependencias de picom instaladas"

# Clonar, compilar e instalar picom
echo "[*] Clonando picom..."
cd "$DOWNLOADS"
git clone https://github.com/yshui/picom.git
echo "[+] Picom clonado"

echo "[*] Compilando picom..."
cd "$DOWNLOADS/picom" && meson setup --buildtype=release build && ninja -C build
echo "[+] Picom compilado"

echo "[*] Instalando picom..."
cd "$DOWNLOADS/picom" && sudo ninja -C build install
echo "[+] Picom instalado"

# Instalar rofi
echo "[*] Instalando rofi..."
sudo apt install -y rofi
echo "[+] Rofi instalado"

# Registrar bspwm en el gestor de inicio de sesión
echo "[*] Registrando bspwm en el gestor de inicio de sesión..."
sudo cp "$DOWNLOADS/bspwm/contrib/freedesktop/bspwm.desktop" /usr/share/xsessions/
echo "[+] bspwm registrado en /usr/share/xsessions/"


# Instalar Hack Nerd Font
echo "[*] Descargando Hack Nerd Font..."
HACK_URL=$(curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest \
    | grep "browser_download_url.*Hack.zip" \
    | cut -d '"' -f 4)
wget -P "$DOWNLOADS" "$HACK_URL"
echo "[+] Hack Nerd Font descargada"

echo "[*] Instalando Hack Nerd Font..."
sudo mv "$DOWNLOADS/Hack.zip" /usr/local/share/fonts
sudo unzip /usr/local/share/fonts/Hack.zip -d /usr/local/share/fonts
echo "[+] Hack Nerd Font instalada"

sudo apt install -y zsh

# Actualizar kitty a la última versión
echo "[*] Removiendo kitty anterior..."
sudo apt remove -y kitty
echo "[+] Kitty removido"

echo "[*] Descargando última versión de kitty..."
KITTY_URL=$(curl -s https://api.github.com/repos/kovidgoyal/kitty/releases/latest \
    | grep "browser_download_url.*x86_64.txz" \
    | cut -d '"' -f 4)
wget -P "$DOWNLOADS" "$KITTY_URL"
echo "[+] Kitty descargado"

echo "[*] Instalando kitty en /opt..."
KITTY_FILE=$(basename "$KITTY_URL")
sudo mkdir -p /opt/kitty
sudo mv "$DOWNLOADS/$KITTY_FILE" /opt/kitty
sudo 7z x "/opt/kitty/$KITTY_FILE" -o/opt/kitty
sudo tar -xf "/opt/kitty/${KITTY_FILE%.txz}.tar" -C /opt/kitty
echo "[+] Kitty instalado en /opt/kitty"

# Configurar kitty para root
echo "[*] Configurando kitty para root..."
sudo mkdir -p /root/.config/kitty
sudo cp $HOME/.config/kitty/* /root/.config/kitty
echo "[+] Configuración de kitty copiada a root"

sudo apt install -y feh
sudo apt install -y dunst
sudo apt install -y imagemagick

# Clonar blue-sky
echo "[*] Clonando blue-sky..."
cd "$DOWNLOADS"
git clone https://github.com/VaughnValle/blue-sky.git
echo "[+] blue-sky clonado"

# Copiar configuración de polybar
echo "[*] Copiando configuración de polybar..."
cp -r "$DOWNLOADS/blue-sky/polybar/"* "$HOME/.config/polybar"
echo "[+] Configuración de polybar copiada"

# Instalar fuentes de polybar
echo "[*] Instalando fuentes de polybar..."
sudo cp -r "$DOWNLOADS/blue-sky/polybar/fonts" /usr/share/fonts/truetype
echo "[+] Fuentes instaladas"

# Actualizar caché de fuentes
echo "[*] Actualizando caché de fuentes..."
fc-cache -v
echo "[+] Caché de fuentes actualizada"


# Instalar plugins de zsh
echo "[*] Instalando plugins de zsh..."
sudo apt install -y zsh-autosuggestions zsh-syntax-highlighting
echo "[+] Plugins de zsh instalados"


# Instalar powerlevel10k
echo "[*] Instalando powerlevel10k..."
sudo cp -r "$DOWNLOADS/entorno/powerlevel10k" /opt/powerlevel10k
echo "[+] Powerlevel10k instalado"

# Copiar p10k.zsh para usuario normal y root
echo "[*] Configurando p10k.zsh..."
cp "$DOWNLOADS/entorno/p10k.zsh" "$HOME/.p10k.zsh"
sudo cp "$DOWNLOADS/entorno/p10k.zsh" /root/.p10k.zsh
echo "[+] p10k.zsh configurado para $USER y root"

# Copiar zshrc desde el repo
echo "[*] Configurando zshrc..."
cp "$DOWNLOADS/entorno/zshrc" "$HOME/.zshrc"
echo "[+] zshrc configurado"

# Crear enlace simbólico de .zshrc para root
echo "[*] Creando enlace simbólico de .zshrc para root..."
sudo ln -s -f "$HOME/.zshrc" /root/.zshrc
echo "[+] Enlace simbólico creado"

# Instalar plugin sudo para zsh
echo "[*] Instalando plugin sudo para zsh..."
sudo mkdir -p /usr/share/zsh-sudo
sudo wget -P /usr/share/zsh-sudo https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/refs/heads/master/plugins/sudo/sudo.plugin.zsh
echo "[+] Plugin sudo instalado"

# Instalar batcat
echo "[*] Descargando batcat..."
BAT_URL=$(curl -s https://api.github.com/repos/sharkdp/bat/releases/latest \
    | grep "browser_download_url.*amd64.deb" \
    | cut -d '"' -f 4)
wget -P "$DOWNLOADS" "$BAT_URL"
echo "[+] Batcat descargado"

echo "[*] Instalando batcat..."
BAT_FILE=$(basename "$BAT_URL")
sudo dpkg -i "$DOWNLOADS/$BAT_FILE"
echo "[+] Batcat instalado"

# Instalar lsd
echo "[*] Descargando lsd..."
LSD_URL=$(curl -s https://api.github.com/repos/lsd-rs/lsd/releases/latest \
    | grep "browser_download_url.*amd64.deb" \
    | cut -d '"' -f 4)
wget -P "$DOWNLOADS" "$LSD_URL"
echo "[+] lsd descargado"

echo "[*] Instalando lsd..."
LSD_FILE=$(basename "$LSD_URL")
sudo dpkg -i "$DOWNLOADS/$LSD_FILE"
echo "[+] lsd instalado"

touch ~/.config/bin/target

# Instalar fzf para usuario normal
echo "[*] Instalando fzf para $USER..."
git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
"$HOME/.fzf/install" --all
echo "[+] fzf instalado para $USER"

# Instalar fzf para root
echo "[*] Instalando fzf para root..."
sudo git clone --depth 1 https://github.com/junegunn/fzf.git /root/.fzf
sudo /root/.fzf/install --all
echo "[+] fzf instalado para root"



