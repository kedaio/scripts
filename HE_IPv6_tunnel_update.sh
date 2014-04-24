#!/bin/env bash

#######  HE tunnel broker account info  ##############
#######  UPDATE THEM ACCORDING TO YOUR ACCOUNT  ######
tunnel_user=user_name
tunnel_pass=Password00
tunnel_id=xxxxxx

# =====  udate the following according to your HE tunnel info =========
ipv6_addr="2001:470:c:FFFF::2"
ipv6_prefix=64
ipv6_gateway="2001:470:c:FFFF::1"
remote_end_ip=xx.xx.xx.xx

####  the interface used to access internet. Default to ppp0 
####   as this script is meant for ADSL users
ext_int=ppp0

### name of the virutal tunnel interface. change it to what you like
tunnel_int="he-ipv6"

#######  tunnel update URL
#######  according to https://www.tunnelbroker.net/forums/index.php?topic=1994.0
#######  update it in case of any change
tunnel_update_url="https://${tunnel_user}:${tunnel_pass}@ipv4.tunnelbroker.net/nic/update?hostname=${tunnel_id}"

### get IPv4 address assigned to $ext_int
local_ip=$(ip -f inet addr show $ext_int | awk '/inet/ {print $2}')

####  TO BE DONE #####
####   verify $local_ip is in right format

########    not used for now ############
#distro=
#OS=

if [ ! -z $local_ip ]
then
  	echo "   updating HE ipv6 tunnel end point ..."
	ip tunnel add $tunnel_int mode sit remote $remote_end_ip local $local_ip ttl 255
	ip link set $tunnel_int up
	ip addr add ${ipv6_addr}/${ipv6_prefix}  dev ${tunnel_int}
	route add --inet6 default gw $ipv6_gateway
	curl $tunnel_update_url 2>&1 >> /dev/null

	echo "   ....... DONE"
fi

### if necessary, update /etc/resolv.conf and use Ipv6 capable DNS servers
