#!/bin/bash
set -e
CJDROUTE="/opt/cjdns/cjdroute"
CJDROUTECONF="/etc/cjdroute.conf"

$CJDROUTE < $CJDROUTECONF
