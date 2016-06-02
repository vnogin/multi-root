# ------------Mandatory values:-----------
USER_ID - user name

JOB_MODE - possible options: 

  	- upgrade  - upgrade standard image to up to date state
  
  	- backup  - create backup of file system for the defined user
  
  	- list - get list of backups for the defined user
  
  	- restore  - restore from the backup
  
  	- standard - restore file system to standard file system

	- deploy - deploy stack from scratch according to provided info  

Block_Dev_Prov - Which block device provider should be used. 

Possible options:

	 - lvm2

	 - ceph

STACK_USERNAME - DevStack user name

STACK_GROUP	 - DevStack group

USER_FOLDER	 - Folder with user's data

MAPPER - Device mapper path

Mandatory Parameters for LVM:

 	- VG - LVM Volume group name

 	- LV_ROOT_STANDARD - LVM Logical standard volume name

 	- LV_ROOT_FIRST - LVM Logical first root volume name

 	- LV_ROOT_SECOND - LVM Logical second root volume name

 	- LV_OPT - LVM Logical opt volume name

 	- LV_PARTITIONS_LIST - LVM Logical partitions list (root_standard root_one root_two opt_vol)

#-------------Optional values:------------

 GIT_LINK 		 - link to relavant stack repository

 IF_DEPLOYMENT_FAIL_JOB - which job should be started if deployment fail

 BACKUP_ID 		 - which backup ID should be used for recovering. If not defined will be used latest 

----------------End----------------------

