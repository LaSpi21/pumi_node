#!bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
read -e -p "Ingresa la ruta al repositorio (ej. /media/user/repo/)" repo_path

#Completa el archivo /pumi/Repo_path con las rutas e uuids del repositorio y de la carpeta /pumi/

ID_repo=$(sudo blkid -o value -s UUID $(\df --output=source "$repo_path"|tail -1))
repo_mount_point=$(blkid -o device -l -t UUID="$ID_repo")

read -p "Ingresa el nombre de usuario de la imagen: " usr
read -p "Ingresa el nombre de la imagen: " image_name

echo "$image_name" | sudo tee /home/"$usr"/Desktop/.Signature

nombre="$image_name"-img


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
linux (loop)/live/vmlinuz boot=live union=overlay username=user config components quiet noswap edd=on nomodeset enforcing=0 noeject ocs_prerun=\\\"mount UUID="$ID_repo" /mnt\\\" ocs_prerun1=\\\"mount --bind /mnt /home/partimag/\\\" ocs_live_run=\\\"ocs-sr -q2 -c -j2 -z9p -i 4096 -sfsck -scs -senc -p shutdown savedisk "$nombre"\\\" keyboard-layouts=\\\"us\\\" ocs_live_batch=\\\"yes\\\" locales=en_US.UTF-8 vga=788 ip= nosplash net.ifnames=0 splash i915.blacklist=yes radeonhd.blacklist=yes nouveau.blacklist=yes vmwgfx.enable_fbdev=1 findiso="\$ISO" toram
initrdefi (loop)/live/initrd.img
}"
            ;;

        2) 
json=$(lsblk -J)

# Extraer los nombres y tamaños de los discos hijos
children=$(echo "$json" | jq -r '.blockdevices[] | select(has("children")) | .children[] | "\(.name) (\(.size))"')

# Limpiar el array de discos hijos
unset children_array

# Almacenar los discos hijos en un array
declare -a children_array

# Recorrer la cadena de discos hijos y poblar el array con el nombre y el tamaño combinados
while IFS= read -r line; do
    children_array+=("$line")
done <<< "$children"

# Mostrar opciones
echo "Selecciona un disco:"
for ((i=0; i<${#children_array[@]}; i++)); do
    echo "$(($i + 1)) ${children_array[$i]}"
done

# Solicitar al usuario que seleccione un hijo
read -p "Ingresa el número del disco: " choice
if [[ $choice =~ ^[0-9]+$ ]] && ((choice >= 1 && choice <= ${#children_array[@]})); then
    selected_option="${children_array[$(($choice - 1))]}"
    echo "Seleccionaste: $selected_option"
else
    echo "Opción inválida. Por favor ingresa un número entre 1 y ${#children_array[@]}."
fi
disk_name=$(echo "$selected_option" | cut -d' ' -f1)
        
        
        entrada_grub="menuentry 'Restore $nombre'{
ISO="$SCRIPT_DIR/clonezilla.iso"
search --set -f "\$ISO"
loopback loop "\$ISO"
linux (loop)/live/vmlinuz boot=live union=overlay username=user config components quiet noswap edd=on nomodeset enforcing=0 noeject ocs_prerun=\\\"mount UUID="$ID_repo" /mnt\\\" ocs_prerun1=\\\"mount --bind /mnt /home/partimag/\\\" ocs_live_run=\\\"ocs-sr -q2 -c -j2 -z9p -i 4096 -sfsck -scs -senc -p shutdown saveparts "$nombre" "$disk_name"\\\" keyboard-layouts=\\\"us\\\" ocs_live_batch=\\\"yes\\\" locales=en_US.UTF-8 vga=788 ip= nosplash net.ifnames=0 splash i915.blacklist=yes radeonhd.blacklist=yes nouveau.blacklist=yes vmwgfx.enable_fbdev=1 findiso="\$ISO" toram
initrdefi (loop)/live/initrd.img
}"
        ;;
        *)
        echo "Opción no válida. Por favor, selecciona 1 ó 2."
        exit
            ;;
esac


read -p "Estas seguro de copiar $nombre como una imagen?[y/n, default = no]" confirm
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
