#!/bin/bash
set -e
cd /opt
git clone https://github.com/cjdelisle/cjdns
cd cjdns
./do

# Prepare the folders for the tun device. The actual device is created when the
# thing is run
[ -d /dev/net ] || mkdir -p /dev/net
