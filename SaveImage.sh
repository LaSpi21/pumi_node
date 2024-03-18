#!bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
read -e -p "Ingresa la ruta al repositorio (ej. /media/user/repo/)" repo_path

#Completa el archivo /pumi/Repo_path con las rutas e uuids del repositorio y de la carpeta /pumi/

ID_repo=$(sudo blkid -o value -s UUID $(\df --output=source "$repo_path"|tail -1))
repo_mount_point=$(blkid -o device -l -t UUID="$ID_repo")

nombre=$(cat /home/tareas/Desktop/.Signature)-img


echo "Es la imagen un disco o una partición?"
echo "1. Disco"
echo "2. Partición"
read opcion

#Definir la entrada de GRUB

case $opcion in
        1) entrada_grub="menuentry 'Restore $nombre'{
ISO="$SCRIPT_DIR/clonezilla.iso"
search --set -f "\$ISO"
loopback loop "\$ISO"
linux (loop)/live/vmlinuz boot=live union=overlay username=user config components quiet noswap edd=on nomodeset enforcing=0 noeject ocs_prerun=\\\"mount UUID="$ID_repo" /mnt\\\" ocs_prerun1=\\\"mount --bind /mnt /home/partimag/\\\" ocs_live_run=\\\"ocs-sr -q2 -c -j2 -z9p -i 4096 -sfsck -scs -senc -p shutdown saveparts "$nombre"\\\" keyboard-layouts=\\\"us\\\" ocs_live_batch=\\\"yes\\\" locales=en_US.UTF-8 vga=788 ip= nosplash net.ifnames=0 splash i915.blacklist=yes radeonhd.blacklist=yes nouveau.blacklist=yes vmwgfx.enable_fbdev=1 findiso="\$ISO" toram
initrdefi (loop)/live/initrd.img
}"
            ;;

        2) entrada_grub="menuentry 'Restore $nombre'{
ISO="$SCRIPT_DIR/clonezilla.iso"
search --set -f "\$ISO"
loopback loop "\$ISO"
linux (loop)/live/vmlinuz boot=live union=overlay username=user config components quiet noswap edd=on nomodeset enforcing=0 noeject ocs_prerun=\\\"mount UUID="$ID_repo" /mnt\\\" ocs_prerun1=\\\"mount --bind /mnt /home/partimag/\\\" ocs_live_run=\\\"ocs-sr -q2 -c -j2 -z9p -i 4096 -sfsck -scs -senc -p shutdown saveparts "$nombre" sda2\\\" keyboard-layouts=\\\"us\\\" ocs_live_batch=\\\"yes\\\" locales=en_US.UTF-8 vga=788 ip= nosplash net.ifnames=0 splash i915.blacklist=yes radeonhd.blacklist=yes nouveau.blacklist=yes vmwgfx.enable_fbdev=1 findiso="\$ISO" toram
initrdefi (loop)/live/initrd.img
}"
        ;;
        *)
        echo "Opción no válida. Por favor, selecciona 1 ó 2."
        exit
            ;;
esac


read -p "Estas seguro de copiar $nombre_e como una imagen?[y/n, default = no]" confirm
if [ "$confirm" = y ]; then
  echo agregando "$nombre"

  # Agregar la entrada de GRUB al archivo de configuración
  echo "$entrada_grub" | sudo tee -a /etc/grub.d/40_custom > /dev/null

  # Actualizar GRUB
  sudo update-grub
  sudo /usr/sbin/grub-reboot "Restore $nombre"
  /sbin/reboot

else
echo Cancelando..
fi
