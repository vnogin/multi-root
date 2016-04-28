#===============================================================================
#
#          FILE:  check_lvm2_ubuntu.sh
#
#         USAGE:  ./check_lvm2_ubuntu.sh
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
#       CREATED:  21/04/2016 13:10:01 PM MDT
#      REVISION:  ---
#===============================================================================

check_lvm2_ubuntu()
{
# LVM2 package is installed check 
LVM2_PACKAGE_STATE=`dpkg -l | grep ^ii | sed 's_  _\t_g' | cut -f 2 | grep lvm2`
# LVM2 module is loaded check
LVM2_MODULE_STATE=`lsmod | grep dm_multipath | cut -d' ' -f1 | grep dm_multipath`

if [ "${LVM2_PACKAGE_STATE}" == "lvm2" ]
then
        echo "[INFO]: ${LVM2_PACKAGE_STATE} package is installed."
else
        echo "[ERROR]: ${LVM2_PACKAGE_STATE} package isn't installed."
        exit
fi

#if [ "${LVM2_MODULE_STATE}" == "dm_multipath" ]
#then
#        echo "[INFO]: ${LVM2_MODULE_STATE} module is loaded."
#else
#        echo "[ERROR]: ${LVM2_MODULE_STATE} module isn't loaded."
#        exit
#fi
}
