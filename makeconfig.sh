#!/bin/bash
set -e
CJDROUTE="/opt/cjdns/cjdroute"
CJDROUTECONF="/etc/cjdroute.conf"

# Create the tun device. /dev/net should have been created in the cjdns
# install, but we're checking just in case.
[ -d /dev/net ] || mkdir -p /dev/net
[ -c /dev/net/tun ] || mknod /dev/net/tun c 10 200 ||
    echo "Permission errors making the tun device! Did you run with --privileged?"

IP4=$(ip addr show dev eth0 | grep "inet " | awk '{print $2}' | cut -d'/' -f1)

if ! [ -e $CJDROUTECONF ]; then
    ( # start a subshell to avoid side effects of umask later on
        umask 077 # to create the file with 600 permissions without races
        $CJDROUTE --genconf | $CJDROUTE --cleanconf < /dev/stdin > $CJDROUTECONF
    ) # exit subshell; umask no longer applies
    KEY=$(cat $CJDROUTECONF | jq -r .publicKey)
    ADDR=$(cat $CJDROUTECONF | jq -r .ipv6)
    ADMINPW=$(cat /etc/cjdroute.conf | jq .admin.password)
    echo "NEW CONFIGURATION GENERATED!"
    echo "PUBLIC KEY: $KEY"
    echo "ADDRESS: $ADDR"
    echo "{\"password\": $ADMINPW, \"addr\": \"$IP4\", \"port\": 11234}" | jq .
    echo "{\"password\": $ADMINPW, \"addr\": \"$IP4\", \"port\": 11234, \"config\": \"/etc/cjdroute.conf\"}" | jq . > /root/.cjdnsadmin
fi

# This python script preforms a series of operations that to edit the config.
# All of these are much easier to do in python, hence the language switch
/opt/editconf.py $CJDROUTECONF

cd /opt/cjdns/contrib/nodejs/admin
sed -i "s/'127.0.0.1',//g" /opt/cjdns/contrib/nodejs/admin/admin.js
npm install

$CJDROUTE < $CJDROUTECONF

echo "Visit http://$IP4:8084/ for HTTP admin interface"
nodejs /opt/cjdns/contrib/nodejs/admin/admin.js
