#!/usr/bin/env bash

# start ovs service
service openvswitch-switch start
ovs-vsctl set-manager ptcp:6640

# start mininet scenario
echo " * Custom: Start Mininet"
mn --controller=remote,ip=172.17.0.2,port=6633  --switch ovs,protocols=OpenFlow13  --topo=single,4

bash
