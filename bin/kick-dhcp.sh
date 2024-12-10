#!/bin/bash
# A little something to handle resetting DHCP on Debian servers when the router reboots
export PATH=/usr/bin:/usr/sbin
if ! host $(hostname); then
	default_if=$(netstat -rn | awk '$1=="0.0.0.0"{print $NF}')
	ifdown "$default_if"
	ifup "$default_if"
fi

