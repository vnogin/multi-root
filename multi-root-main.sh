#!/bin/bash
#===============================================================================
#
#          FILE:  multi-root-main.sh
#
#         USAGE:  ./multi-root-main.sh --conf <path to configuration file>
#
#   DESCRIPTION:
#
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Vitalii Nogin	vnogin@mirantis.com
#       COMPANY:  Mirantis Inc.
#       VERSION:  1.0
#       CREATED:  20/04/2016 14:31:01 PM MDT
#      REVISION:  ---
#===============================================================================

ERROR="\e[31m[ERROR]\e[0m:"
INFO="\e[92m[INFO]:\e[0m:"

BASE_DIR=$(dirname "$0")
source ${BASE_DIR}/utils/check_os.sh

############SHOULD BE REVIEWED################
#-----------------------------------------
#BASE_DIR=$(dirname "$0")
HOSTNAME=`hostname`
source ${BASE_DIR}/utils/check_lvm_centos.sh
source ${BASE_DIR}/utils/check_lvm_ubuntu.sh
source ${BASE_DIR}/utils/upgrade_standard_ubuntu.sh
source ${BASE_DIR}/utils/vg_lv_check.sh
source ${BASE_DIR}/utils/create_backup_lvm.sh
source ${BASE_DIR}/utils/list_backups.sh
source ${BASE_DIR}/utils/restore_backup_lvm.sh

#----------------------------------------------
##################################################


usage ()
{
  echo 'Usage : ./multi-root-main.sh' 
  echo '		--conf 		<path to configuration file> '
  exit
}

config_error()
{
  echo "[ERROR]: Please check your configuration file as it seems something hasn't been defined."
  exit
}


let AMOUNT_INPUT_PARAMS=$#

if [ "${AMOUNT_INPUT_PARAMS}" -lt 2 ]
then
  usage
fi

if [ "${AMOUNT_INPUT_PARAMS}" -gt 3 ]
then
  usage
fi

while [ "$1" != "" ]; do
    case $1 in
        --conf )       shift
                       CONFIG_FILE=$1
                       ;;
    esac
    shift
done

# Empty parameter validation 
if [ "${CONFIG_FILE}" = "" ]
then
    usage
fi

# File exists check
if [ -s "${CONFIG_FILE}" ]
then
	CONFIG_OPTIONS=`cat ${CONFIG_FILE}`
else
	echo "[ERROR]: Please provide correct path to the configuration file as ${CONFIG_FILE} file doesn't exist or empty"
fi

source ${CONFIG_FILE}

# Mandatory configuration parameters are defined in configuration file

if [ "${USER_ID}" = "" ]
then
    config_error
fi

if [ "${JOB_MODE}" = "" ]
then
    config_error
fi

if [ "${BLOCK_DEVICE_PROVIDER}" = "" ]
then
    config_error
fi

# Block device provider review
case ${BLOCK_DEVICE_PROVIDER} in
  lvm2)
	echo "[INFO] ${BLOCK_DEVICE_PROVIDER} will be used as block device provider"
	;;
  ceph)
	echo "[INFO] ${BLOCK_DEVICE_PROVIDER} will be used as block device provider"
	;;
   *)  
      echo "[ERROR]: ${BLOCK_DEVICE_PROVIDER} block device provider isn't supported. Please check your configuration file." 
      exit
      ;; 
esac

check_os
OS=$?
case ${OS} in
   1) # 1 - means UBUNTU
        if [ "${BLOCK_DEVICE_PROVIDER}" == "lvm2" ]; then
              	check_lvm2_ubuntu
		vg_lv_check
        elif [ "${BLOCK_DEVICE_PROVIDER}" == "ceph" ]; then
               	echo "[ERROR]: Sorry, ${BLOCK_DEVICE_PROVIDER} functionality hasn't been implemented yet."
		exit
        fi
        ;;
   2) # 2 - means CENTOS
        if [ "${BLOCK_DEVICE_PROVIDER}" == "lvm2" ]; then
              	check_lvm2_centos
		vg_lv_check
        elif [ "${BLOCK_DEVICE_PROVIDER}" == "ceph" ]; then
              	echo "[ERROR]: Sorry, ${BLOCK_DEVICE_PROVIDER} functionality hasn't been implemented yet."
		exit
        fi
              ;;
esac

case ${JOB_MODE} in
  upgrade)
		echo "[INFO]: Running upgrade mode"
		upgrade_standard_ubuntu
		;;
  backup)
                echo "[INFO]: Running backup mode"
		create_backup_lvm
                ;;
  list)
                echo "[INFO]: Running list mode"
		list_backups
                ;;
  restore)
                echo "[INFO]: Running restore mode"
		restore_backup_lvm
                ;;
  standard)
                echo "[INFO]: Running standard mode"
                ;;
  deploy)
                echo "[INFO]: Running deploy mode. Checking local.conf and git link"
                ;;
  *)  
      echo "[ERROR]: ${JOB_MODE} mode isn't supported. Please check your configuration file." 
      exit
      ;; 
esac

echo "[DEBUG]: USER-ID from config is ${USER_ID} | JOB_MODE=${JOB_MODE} | GIT_LINK=${GIT_LINK} | IF_DEPLOYMENT_FAIL_JOB=${IF_DEPLOYMENT_FAIL_JOB} | BLOCK_DEVICE_PROVIDER=${BLOCK_DEVICE_PROVIDER} | OS=${OS}"
echo "[DEBUG]: CONFIG FILE = ${CONFIG_FILE} LV_PARTITIONS_LIST=${LV_PARTITIONS_LIST}"























