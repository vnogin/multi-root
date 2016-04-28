restore_backup_lvm()
{
if [ "${BACKUP_ID}" == "" ]; then
	echo -e "${ERROR} BACKUP_ID is empty. Please check your configuration."
	exit
fi

# Mandatory backup folders exist checks
if [ -d "$BASE_DIR/backups/${BACKUP_ID}/rootfs" ]; then
	echo -e "${INFO} $BASE_DIR/backups/${BACKUP_ID}/rootfs folder is OK"
else
	echo -e "${ERROR} $BASE_DIR/backups/${BACKUP_ID}/rootfs folder doesn't exist."
	exit
fi

if [ -d "$BASE_DIR/backups/${BACKUP_ID}/userdata" ]; then
        echo -e "${INFO} $BASE_DIR/backups/${BACKUP_ID}/userdata folder is OK"
else
        echo -e "${ERROR} $BASE_DIR/backups/${BACKUP_ID}/userdata folder doesn't exist."
        exit
fi

LV_POSITIONAL_ROOTS="${VG}-${LV_ROOT_FIRST} ${VG}-${LV_ROOT_SECOND}"
LV_CURRENT_ROOT=`mount| egrep "${VG}-${LV_ROOT_STANDARD}|${VG}-${LV_ROOT_FIRST}|${VG}-${LV_ROOT_SECOND}"|grep remount-ro|awk 'BEGIN{FS="/"}{print $4}'|awk '{print $1}'`

if [ "${LV_CURRENT_ROOT}" != "" ]; then
        echo "[INFO]: Current root file system is ${LV_CURRENT_ROOT}"
else
        echo "[ERROR]: There isn't required root partition"
        exit
fi

#Determine current and future partitions
if [ "${LV_CURRENT_ROOT}" == "${VG}-${LV_ROOT_STANDARD}" ]; then
        LV_FUTURE_ROOT="${VG}-${LV_ROOT_FIRST}"
else
	for LV_POSITIONAL_ROOT in ${LV_POSITIONAL_ROOTS}
        do
           if [ "${LV_POSITIONAL_ROOT}" != "${LV_CURRENT_ROOT}" ]; then
               LV_FUTURE_ROOT=${LV_POSITIONAL_ROOT}
               echo "[INFO]: New root will be ${LV_FUTURE_ROOT}"
           fi
        done
fi

LV_CURRENT_ROOT_UUID=`blkid ${MAPPER}${LV_CURRENT_ROOT} | awk '{print $2}'| awk 'BEGIN {FS="\""}{print $2}'`
LV_FUTURE_ROOT_UUID=`blkid ${MAPPER}${LV_FUTURE_ROOT} | awk '{print $2}'| awk 'BEGIN {FS="\""}{print $2}'`


mount "${MAPPER}${LV_FUTURE_ROOT}" "${BASE_DIR}/mnt/destination_fs"
if [ $? -eq 0 ]; then
        echo "[INFO]: ${MAPPER}${LV_FUTURE_ROOT} has been mounted to ${BASE_DIR}/mnt/destination_fs folder."
else
        echo "[ERROR]:${MAPPER}${LV_FUTURE_ROOT} hasn't been mounted to ${BASE_DIR}/mnt/destination_fs folder."
        exit
fi

echo "[INFO]: RSYNCing $BASE_DIR/backups/${BACKUP_ID}/rootfs/ $BASE_DIR/mnt/destination_fs/"
rsync -av --delete --exclude "/dev/*" "$BASE_DIR/backups/${BACKUP_ID}/rootfs/" "$BASE_DIR/mnt/destination_fs/" 1>/dev/null
if [ $? -eq 0 ]; then
        echo "[INFO]: Root file system has been stored under $BASE_DIR/mnt/destination_fs/"
#        umount "${BASE_DIR}/mnt/destination_fs"
#        echo "[INFO]: ${BASE_DIR}/mnt/destination_fs/ mount point has been umounted"
else
        echo "[ERROR]: Root file system hasn't been stored."
        umount "${BASE_DIR}/mnt/destination_fs/"
        echo "[INFO]: ${BASE_DIR}/mnt/destination_fs/ mount point has been umounted"
        exit
fi

echo "[INFO]: RSYNCing $BASE_DIR/backups/${BACKUP_ID}/userdata/ ${USER_FOLDER}"
rsync -av --delete "$BASE_DIR/backups/${BACKUP_ID}/userdata/" ${USER_FOLDER} 1>/dev/null
if [ $? -eq 0 ]; then
        echo "[INFO]: User's data folder has been stored under ${USER_FOLDER} folder."
else
        echo "[ERROR]: User's data folder hasn't been stored."
        exit
fi

echo "[INFO]:  has been finished"

sed -i "s/${LV_CURRENT_ROOT}/${LV_FUTURE_ROOT}/g" "${BASE_DIR}/mnt/destination_fs/etc/fstab"
if [ $? -eq 0 ]; then
        echo "[INFO]: ${BASE_DIR}/mnt/destination_fs/etc/fstab file has been changed."
else
        echo "[ERROR]: ${BASE_DIR}/mnt/destination_fs/etc/fstab file hasn't been changed."
        exit
fi


sed -i "s/${LV_CURRENT_ROOT_UUID}/${LV_FUTURE_ROOT_UUID}/g" /boot/grub/grub.cfg
if [ $? -eq 0 ]; then
        echo "[INFO]: UUID info in /boot/grub/grub.cfg file has been changed."
else
        echo "[ERROR]: UUID info in /boot/grub/grub.cfg file hasn't been changed."
        exit
fi

sed -i "s/${LV_CURRENT_ROOT}/${LV_FUTURE_ROOT}/g" /boot/grub/grub.cfg
if [ $? -eq 0 ]; then
        echo "[INFO]: Information regarding ${LV_FUTURE_ROOT} has been added in /boot/grub/grub.cfg file."
else
        echo "[ERROR]: Information regarding ${LV_FUTURE_ROOT} hasn't been added in /boot/grub/grub.cfg file."
        exit
fi

umount "${BASE_DIR}/mnt/destination_fs"
if [ $? -eq 0 ]; then
        echo "[INFO]: ${BASE_DIR}/mnt/destination_fs/ mount point has been umounted"
else
	echo "[ERROR]: ${BASE_DIR}/mnt/destination_fs/ mount point hasn't been umounted"
	exit
fi
echo "[INFO]: Server rebooting procedure has been started..."
reboot
}



























