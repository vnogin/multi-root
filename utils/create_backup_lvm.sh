create_backup_lvm()
{
if [ -z ${BUILD_NUMBER+x} ]
then
    JOBSTAMP=`date +%F-%H-%M`
else
    JOBSTAMP="${BUILD_NUMBER}"
fi

BACKUP_FULL_PATH="${BASE_DIR}/backups/${HOSTNAME}_${USER_ID}_${JOBSTAMP}"

LV_CURRENT_ROOT=`mount| egrep "${VG}-${LV_ROOT_STANDARD}|${VG}-${LV_ROOT_FIRST}|${VG}-${LV_ROOT_SECOND}"|grep remount-ro|awk 'BEGIN{FS="/"}{print $4}'|awk '{print $1}'`
if [ "${LV_CURRENT_ROOT}" != "" ]; then
	echo "[INFO]: Current root file system is ${LV_CURRENT_ROOT}"
else
	echo "[ERROR]: There isn't required root partition"
	exit
fi

echo "[INFO]: Creating new backup of DevStack environment"
mkdir -p "${BACKUP_FULL_PATH}/rootfs"
mkdir -p "${BACKUP_FULL_PATH}/userdata"
mount "${MAPPER}${LV_CURRENT_ROOT}" "${BASE_DIR}/mnt/source_fs"
if [ $? -eq 0 ]; then
	echo "[INFO]: ${MAPPER}${LV_CURRENT_ROOT} has been mounted to ${BASE_DIR}/mnt/source_fs folder."
else
	echo "[ERROR]:${MAPPER}${LV_CURRENT_ROOT} hasn't been mounted to ${BASE_DIR}/mnt/source_fs folder."
	exit
fi

echo "[INFO]: RSYNCing $BASE_DIR/mnt/source_fs/ to ${BACKUP_FULL_PATH}/rootfs"
rsync -av --delete --exclude "/dev/*" "$BASE_DIR/mnt/source_fs/" "${BACKUP_FULL_PATH}/rootfs" 1>/dev/null
if [ $? -eq 0 ]; then
	echo "[INFO]: Root file system has been stored under ${BACKUP_FULL_PATH}/rootfs folder."
	umount "${BASE_DIR}/mnt/source_fs/"
	echo "[INFO]: ${BASE_DIR}/mnt/source_fs/ mount point has been umounted"
else
	echo "[ERROR]: Root file system hasn't been stored."
	umount "${BASE_DIR}/mnt/source_fs/"
	echo "[INFO]: ${BASE_DIR}/mnt/source_fs/ mount point has been umounted"
	exit
fi

echo "[INFO]: RSYNCing ${USER_FOLDER} to ${BACKUP_FULL_PATH}/userdata"
rsync -av --delete ${USER_FOLDER} "${BACKUP_FULL_PATH}/userdata" 1>/dev/null
if [ $? -eq 0 ]; then
	echo "[INFO]: User's data folder has been stored under ${BACKUP_FULL_PATH}/userdata folder."
else
        echo "[ERROR]: User's data folder hasn't been stored."
        exit
fi

echo "[INFO]: Backup has been finished"
}
