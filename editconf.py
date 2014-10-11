#!/usr/bin/env python
import json
import sys
import os

CONF = json.load(open(sys.argv[1]))

## First, add all ethernet interfaces that are of type 1
EXISTINGIFACES = []
if "ETHInterface" in CONF['interfaces']:
    for interface in CONF['interfaces']['ETHInterface']:
        EXISTINGIFACES.append(interface['bind'])
else:
    CONF['interfaces']['ETHInterface'] = []

for dev in os.listdir("/sys/class/net"):
    if not dev in EXISTINGIFACES:
        # What is a good way to detect physical vs virtual devices? I highly
        # doubt this is way is any good
        iftype = open("/sys/class/net/%s/type" % dev).read().strip()
        if iftype == "1":
            print "Adding ETHInterface to %s" % dev
            CONF['interfaces']['ETHInterface'].append({
                "connectTo": {},
                "bind": dev,
                "beacon": 2
            })
        else:
            print "Ignoring %s because it's the wrong type (%s)" % (dev, iftype)
    else:
        print "ETHInterface already set up for %s" % dev

# Next update the config based on the settings in settings/config.json
# (or ./config.json.dist if that fails)
try:
    CONF.update(json.load(open("/tmp/settings/config.json")))
except (ValueError, IOError) as err:
    print "settings/config.json has issues (%s), using config.json.dist" % err
    CONF.update(json.load(open("/tmp/settings/config.json.dist")))

# Finally, add any UDP peers that may be in /tmp/settings/peers
try:
    PEERS = json.load(open("/tmp/settings/peers.json"))
    for peer in PEERS:
        CONF['interfaces']['UDPInterface'][0]['connectTo'][peer] = PEERS[peer]
except ValueError as err:
    print "Failed to add /tmp/settings/peers.json(%s)" % err
SAVE = open(sys.argv[1], "w")
SAVE.write(json.dumps(CONF, sort_keys=True, indent=4, separators=(',', ': ')))
SAVE.close()
