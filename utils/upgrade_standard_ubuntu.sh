#===============================================================================
#
#          FILE:  upgrade_standard_ubuntu.sh
#
#         USAGE:  ./upgrade_standard_ubuntu.sh
#
#   DESCRIPTION:
#
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Vitalii Nogin vnogin@mirantis.com and Ihor Pukha ipukha@mirantis.com
#       COMPANY:  Mirantis Inc.
#       VERSION:  1.0
#       CREATED:  22/04/2016 14:40:01 PM MDT
#      REVISION:  ---
#===============================================================================

upgrade_standard_ubuntu()
{
#update in chroot etalon root partition
            mount "${MAPPER}${VG}-${LV_ROOT_STANDARD}" $BASE_DIR/mnt
            mount -o bind /dev $BASE_DIR/mnt/dev
            mount -t proc proc $BASE_DIR/mnt/proc
            mount -o bind /boot $BASE_DIR/mnt/boot
            mount -o bind /run $BASE_DIR/mnt/run
            chroot $BASE_DIR/mnt /bin/bash -c "source /etc/profile && apt-get -y --force-yes update && apt-get -y --force-yes upgrade"
            sleep 10
            umount $BASE_DIR/mnt/dev
            umount $BASE_DIR/mnt/proc
            umount $BASE_DIR/mnt/boot
	    umount $BASE_DIR/mnt/run
            umount $BASE_DIR/mnt

echo "[INFO]: Standard ubuntu partition updated."
}
