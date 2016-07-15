#===============================================================================
#
#          FILE:  change_boot.sh
#
#         USAGE:  
#
#   DESCRIPTION:
#
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Vitalii Nogin vnogin@mirantis.com
#       COMPANY:  Mirantis Inc.
#       VERSION:  1.0
#       CREATED:  15/06/2016 12:50:01 PM MDT
#      REVISION:  ---
#===============================================================================

# Checking is there boot partition or not. If NOT - boot option will be changed in boot config file from the provided backup
change_boot()
{
BOOT_PARTITION_STATE=`mount | awk '{print $3}' | grep "/boot"`
#if [ "${BOOT_PARTITION_STATE}" != "" ]; then
echo "[INFO]: Changing boot options:"
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

if [ "${BOOT_PARTITION_STATE}" = "" ]; then
        echo "[INFO]: Boot partition doesn't exist. Changing boot options on the destination file system as well:"
        sed -i "s/${LV_CURRENT_ROOT_UUID}/${LV_FUTURE_ROOT_UUID}/g" ${BASE_DIR}/mnt/destination_fs/boot/grub/grub.cfg
        if [ $? -eq 0 ]; then
                echo "[INFO]: UUID info in ${BASE_DIR}/mnt/destination_fs/boot/grub/grub.cfg file has been changed."
        else
                echo "[ERROR]: UUID info in ${BASE_DIR}/mnt/destination_fs/boot/grub/grub.cfg file hasn't been changed."
                exit
        fi

        sed -i "s/${LV_CURRENT_ROOT}/${LV_FUTURE_ROOT}/g" ${BASE_DIR}/mnt/destination_fs/boot/grub/grub.cfg
        if [ $? -eq 0 ]; then
                echo "[INFO]: Information regarding ${LV_FUTURE_ROOT} has been added in ${BASE_DIR}/mnt/destination_fs/boot/grub/grub.cfg file."
        else
                echo "[ERROR]: Information regarding ${LV_FUTURE_ROOT} hasn't been added in ${BASE_DIR}/mnt/destination_fs/boot/grub/grub.cfg file."
                exit
        fi
fi
}
