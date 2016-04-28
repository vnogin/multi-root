#===============================================================================
#
#          FILE:  vg_lv_check.sh
#
#         USAGE:  ./vg_lv_check.sh
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
#       CREATED:  22/04/2016 13:54:01 PM MDT
#      REVISION:  ---
#===============================================================================

vg_lv_check()
{
# Check free space in volume group
VG_FREE_SPACE=`vgs ${VG} --units b -o vg_free --noheadings --nosuffix 2>/dev/null | sed 's/^[ ]*//'`

if [ ! -z ${VG_FREE_SPACE} ]; then
	echo "[INFO]: There is ${VG_FREE_SPACE} free space in ${VG}"
else
	echo "[ERROR]: There isn't ${VG} volume group"
	exit
fi

LV_LIST=`lvs ${VG} -o lv_name --noheadings | sed 's/^[ ]*//'`

if [ "${LV_LIST}" != "" ]; then
	MANDATORY_STATE="true"
	for MANDATORY_LV in ${LV_PARTITIONS_LIST} 
       	  do
	 	LV_STATE="false"
		for CURRENT_LV in ${LV_LIST}
		  do
			if [ ${CURRENT_LV} == ${MANDATORY_LV} ] ; then
				LV_STATE="true"
			fi
		  done
		if [ ${LV_STATE} == "false" ] ; then
			echo "[ERROR]: Please create ${MANDATORY_LV} partition"	
			MANDATORY_STATE='false'
		fi
	  done
	  if [ ${MANDATORY_STATE} == "false" ] ; then
		echo "[ERROR]: Please create mandatory partitions mentioned the above."
		exit
	  else
		echo "[INFO]: All mandatory partitions are OK."
	  fi
else
	echo "[ERROR]: There isn't any logical partition in ${VG} volume group. Please create them."
fi
}
