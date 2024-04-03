#!bin/bash

sudo apt install ethtool -y
sudo ethtool -s enp1s0 wol g #cambiar enp1s0 por el nombre de la interfaz de red adecuada de ser necesario
sudo systemctl enable –now -wol
sudo systemctl edit wol.service –full –force
sudo apt install openssh-server -y
sudo apt install jq
sudo systemctl enable ssh
sudo ufw allow ssh
echo "tareas ALL=(ALL) NOPASSWD: /sbin/shutdown" | sudo tee -a /etc/sudoers
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
sudo sed -i "2i\DIR=$SCRIPT_DIR" "$SCRIPT_DIR"/SaveImage
sudo mv $SCRIPT_DIR/SaveImage /usr/local/bin
sudo chmod +x /usr/local/bin/SaveImage
wget -O "$SCRIPT_DIR"/clonezilla.iso https://sourceforge.net/projects/clonezilla/files/clonezilla_live_stable/3.1.2-9/clonezilla-live-3.1.2-9-amd64.iso/download?use_mirror=sitsa
