#################
# Show config ovs, links and controller
ovs-vsctl show
# output:
#    4ace4ce6-c77a-480a-977b-d003977d363c
#    Manager "ptcp:6640"
#    Bridge "s1"
#        Controller "tcp:172.17.0.3:6633"
#            is_connected: true
#        fail_mode: secure
#        Port "s1-eth2"
#            Interface "s1-eth2"
#        Port "s1-eth3"
#            Interface "s1-eth3"
#        Port "s1"
#            Interface "s1"
#                type: internal
#        Port "s1-eth1"
#            Interface "s1-eth1"
#    ovs_version: "2.9.8"

#################
# Show setup bridge s1
ovs-ofctl show s1 -O OpenFlow13
# output:
#    OFPT_FEATURES_REPLY (OF1.3) (xid=0x2): dpid:0000000000000001
#    n_tables:254, n_buffers:0
#    capabilities: FLOW_STATS TABLE_STATS PORT_STATS GROUP_STATS QUEUE_STATS
#    OFPST_PORT_DESC reply (OF1.3) (xid=0x3):
#     1(s1-eth1): addr:6a:14:c2:32:62:e6
#         config:     0
#         state:      LIVE
#         current:    10GB-FD COPPER
#         speed: 10000 Mbps now, 0 Mbps max
#     2(s1-eth2): addr:4a:0a:2a:dc:99:99
#         config:     0
#         state:      LIVE
#         current:    10GB-FD COPPER
#         speed: 10000 Mbps now, 0 Mbps max
#     3(s1-eth3): addr:32:f0:5c:97:1c:a9
#         config:     0
#         state:      LIVE
#         current:    10GB-FD COPPER
#         speed: 10000 Mbps now, 0 Mbps max
#     LOCAL(s1): addr:ca:fc:24:70:19:48
#         config:     PORT_DOWN
#         state:      LINK_DOWN
#         speed: 0 Mbps now, 0 Mbps max
#    OFPT_GET_CONFIG_REPLY (OF1.3) (xid=0x7): frags=normal miss_send_len=0

#################
# Set remote controller
ovs-vsctl set-controller s1 tcp:172.17.0.3:6633
# output empty:

#################
# Delete all controllers of bridge
ovs-vsctl del-controller s1
# output empty:

#################
# Dump Flows
ovs-ofctl dump-flows s1 -O OpenFlow13
# output:
#    cookie=0xa, duration=108.137s, table=0, n_packets=38, n_bytes=2864, send_flow_rem priority=0 actions=CONTROLLER:65535
#    cookie=0x0, duration=17.164s, table=0, n_packets=0, n_bytes=0, actions=NORMAL

#################
# Add Flow
## Setup SW Normal
ovs-ofctl add-flow s1 action=normal -O OpenFlow13
## Setup SW Layer 1
ovs-ofctl add-flow s1 priority=500,in_port=1,actions=output:2 -O OpenFlow13
ovs-ofctl add-flow s1 priority=500,in_port=2,actions=output:1 -O OpenFlow13
## Setup SW Layer 2
ovs-ofctl add-flow s1 dl_src=00:00:00:00:00:01,dl_dst=00:00:00:00:00:02,actions=output:2 -O OpenFlow13
ovs-ofctl add-flow s1 dl_src=00:00:00:00:00:02,dl_dst=00:00:00:00:00:01,actions=output:1 -O OpenFlow13
sh ovs-ofctl add-flow s1 dl_type=0x806,nw_proto=1,action=flood # enable ARP
#ovs-ofctl add-flow s1 dl_src=16:b0:2e:50:1e:d5,dl_dst=da:78:7c:33:2a:2f,actions=output:2 -O OpenFlow13
#ovs-ofctl add-flow s1 dl_src=da:78:7c:33:2a:2f,dl_dst=16:b0:2e:50:1e:d5,actions=output:1 -O OpenFlow13
## Setup SW Layer 3
ovs-ofctl add-flow s1 priority=500,dl_type=0x800,nw_src=10.0.0.0/24,nw_dst=10.0.0.0/24,actions=normal -O OpenFlow13
ovs-ofctl add-flow s1 arp,nw_dst=10.0.0.1,actions=output:1 -O OpenFlow13 # enable ARP
ovs-ofctl add-flow s1 arp,nw_dst=10.0.0.2,actions=output:2 -O OpenFlow13 # enable ARP
ovs-ofctl add-flow s1 arp,nw_dst=10.0.0.3,actions=output:3 -O OpenFlow13 # enable ARP


#################
# Delete Flows
ovs-ofctl del-flows s1 -O OpenFlow13
# output empty: