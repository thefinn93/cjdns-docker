#!/bin/bash
set -e
CJDROUTE="/opt/cjdns/cjdroute"
CJDROUTECONF="/etc/cjdroute.conf"

# Create the tun device. /dev/net should have been created in the cjdns
# install, but we're checking just in case.
[ -d /dev/net ] || mkdir -p /dev/net
[ -c /dev/net/tun ] || mknod /dev/net/tun c 10 200 || 
    echo "Permission errors making the tun device! Did you run with --privileged?"

if ! [ -e $CJDROUTECONF ]; then
    ( # start a subshell to avoid side effects of umask later on 
        umask 077 # to create the file with 600 permissions without races
        $CJDROUTE --genconf | $CJDROUTE --cleanconf < /dev/stdin > $CJDROUTECONF
    ) # exit subshell; umask no longer applies
    KEY=$(cat $CJDROUTECONF | jq -r .publicKey)
    ADDR=$(cat $CJDROUTECONF | jq -r .ipv6)
    echo "NEW CONFIGURATION GENERATED!"
    echo "PUBLIC KEY: $KEY"
    echo "ADDRESS: $ADDR"
fi

# Add all ethernet devices to the ETHInterface, enable auto-pering on them
# This script also sets noBackground: 1, simply because it was the easiest
# plce to put it. JSON in bash is hard :(
/opt/addeth.py $CJDROUTECONF

$CJDROUTE < $CJDROUTECONF
