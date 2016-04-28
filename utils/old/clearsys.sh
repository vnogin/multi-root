#!/bin/bash


if [ -z ${BUILD_NUMBER+x} ]
then
    tstamp=`date +%F-%H-%M`
else
    tstamp="${BUILD_NUMBER}-${BUILD_USER_ID}"    
fi


if [ -f /opt/laststamp ]
    then
        laststamp=`cat /opt/laststamp`
    else
        laststamp="${tstamp}_old"
fi    


pos_roots="vg0-root_one vg0-root_two"
prefix="/dev/mapper/"
pers="vg0-root_standard"

cur_root=`mount|grep root_|grep remount-ro|awk 'BEGIN{FS="/"}{print $4}'|awk '{print $1}'`
echo "${cur_root}"

#determine current and future partitions
if [ "${cur_root}" == "${pers}" ]
    then
        future_root="vg0-root_one"
    else

        for pos_root in ${pos_roots}
        do
            if [ "${pos_root}" == "${cur_root}" ]
               then
        	   echo "It is equal current root is ${prefix}${pos_root}"
               else
        	   future_root=${pos_root}
        	   echo "New root will be ${prefix}${future_root}"
            fi
        done
fi
pers_root_uuid=`blkid ${prefix}${pers}|awk '{print $2}'| awk 'BEGIN {FS="\""}{print $2}'`
cur_root_uuid=`blkid ${prefix}${cur_root}|awk '{print $2}'| awk 'BEGIN {FS="\""}{print $2}'`
future_root_uuid=`blkid ${prefix}${future_root}|awk '{print $2}'| awk 'BEGIN {FS="\""}{print $2}'`
echo "${prefix}${pers} = ${pers_root_uuid} ${prefix}${cur_root} = ${cur_root_uuid} ${prefix}${future_root} =  ${future_root_uuid} "
#creation of new devstack environment

echo "Creating new devstack environment"
sleep 5
mkdir -p /opt/backroot/${laststamp}
mount ${prefix}${cur_root} /mnt/src
rsync -av --delete --exclude "/dev/*" /mnt/src/ /opt/backroot/${laststamp}/
mv /opt/stack /opt/stack_${laststamp}
umount /mnt/src

cp -r /opt/skelstack/ /opt/stack/
chown -R stack:stack /opt/stack

#rsync from standard to new
echo "Creating new rootfs"
sleep 5
mount ${prefix}${pers} /mnt/src
mount ${prefix}${future_root} /mnt/dst
rsync -av --delete /mnt/src/ /mnt/dst/
umount /mnt/src


#change root partition in new /etc/fstab
echo "Changing configuration files"
sleep 5
if [ ${restore} -eq  1 ]
    then
        sed -i "s/${cur_root}/${future_root}/g" /mnt/dst/etc/fstab
    else
        sed -i "s/${pers}/${future_root}/g" /mnt/dst/etc/fstab
fi
sed -i "s/${cur_root_uuid}/${future_root_uuid}/g" /boot/grub/grub.cfg
sed -i "s/${cur_root}/${future_root}/g" /boot/grub/grub.cfg
umount /mnt/dst
echo "${tstamp}" > /opt/laststamp
reboot
