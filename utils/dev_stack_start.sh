#!/usr/bin/env bash

# Define Directories
OS_BIN_ROOT=/opt/stack/
OS_LOG_ROOT=/var/log/openstack
OS_CFG_ROOT=/etc/

OS_BIN_GLANCE=${OS_BIN_ROOT}glance/bin
OS_LOG_GLANCE=${OS_LOG_ROOT} # glance
OS_CFG_GLANCE=${OS_CFG_ROOT}glance

OS_BIN_KEYSTONE=${OS_BIN_ROOT}keystone/bin
OS_LOG_KEYSTONE=${OS_LOG_ROOT} # keystone
OS_CFG_KEYSTONE=${OS_CFG_ROOT}keystone

OS_BIN_NOVA=${OS_BIN_ROOT}nova/bin
OS_LOG_NOVA=${OS_LOG_ROOT} # nova
OS_CFG_NOVA=${OS_CFG_ROOT}nova

# Start Glance

${OS_BIN_GLANCE}/glance-registry --config-file=${OS_CFG_GLANCE}/glance-registry.conf --log-file=${OS_LOG_GLANCE}/glance-registry.log > ${OS_LOG_GLANCE}/glance-registry.out 2>&1 &
${OS_BIN_GLANCE}/glance-api --config-file=${OS_CFG_GLANCE}/glance-api.conf --log-file=${OS_LOG_GLANCE}/glance-api.log > ${OS_LOG_GLANCE}/glance-api.out 2>&1 &

# Start Keystone
${OS_BIN_KEYSTONE}/keystone-all --config-file ${OS_CFG_KEYSTONE}/keystone.conf --log-config ${OS_CFG_KEYSTONE}/logging.conf -d --debug --log-file=${OS_LOG_KEYSTONE}/keystone-all.log > ${OS_LOG_KEYSTONE}/keystone-all.out 2>&1 &

# For some mysterious reason we need to call this command before starting nova-volume
# Not doing this results in a nova-volume failure
sudo losetup -f --show /opt/stack/data/stack-volumes-backing-file

# Not sure the following is always required, anyway it is for launching instances with keys (qemu)
sudo modprobe nbd

# Start Nova
${OS_BIN_NOVA}/nova-api --log-file=${OS_LOG_NOVA}/nova-api.log > ${OS_LOG_NOVA}/nova-api.out 2>&1 &
sg libvirtd ${OS_BIN_NOVA}/nova-compute --log-file=${OS_LOG_NOVA}/nova-compute.log > ${OS_LOG_NOVA}/nova-compute.out 2>&1 &
${OS_BIN_NOVA}/nova-cert --log-file=${OS_LOG_NOVA}/nova-cert.log > ${OS_LOG_NOVA}/nova-cert.out 2>&1 &
${OS_BIN_NOVA}/nova-network --log-file=${OS_LOG_NOVA}/nova-network.log > ${OS_LOG_NOVA}/nova-network.out 2>&1 &
${OS_BIN_NOVA}/nova-scheduler --log-file=${OS_LOG_NOVA}/nova-scheduler.log > ${OS_LOG_NOVA}/nova-scheduler.out 2>&1 &
${OS_BIN_ROOT}/noVNC/utils/nova-novncproxy --config-file ${OS_CFG_NOVA}/nova.conf --web ${OS_BIN_ROOT}/noVNC --log-file=${OS_LOG_NOVA}/nova-novncproxy.log > ${OS_LOG_NOVA}/nova-novncproxy.out 2>&1 &
${OS_BIN_NOVA}/nova-xvpvncproxy --config-file ${OS_CFG_NOVA}/nova.conf --log-file=${OS_LOG_NOVA}/nova-xvpvncproxy.log > ${OS_LOG_NOVA}/nova-xvpvncproxy.out 2>&1 &
${OS_BIN_NOVA}/nova-consoleauth --log-file=${OS_LOG_NOVA}/nova-consoleauth.log > ${OS_LOG_NOVA}/nova-consoleauth.out 2>&1 &
${OS_BIN_NOVA}/nova-objectstore --log-file=${OS_LOG_NOVA}/nova-objectstore.log > ${OS_LOG_NOVA}/nova-objectstore.out 2>&1 &
${OS_BIN_NOVA}/nova-volume --log-file=${OS_LOG_NOVA}/nova-volume.log > ${OS_LOG_NOVA}/nova-volume.out 2>&1 &

