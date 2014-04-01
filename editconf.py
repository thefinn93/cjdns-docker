#!/usr/bin/env python
import json
import sys
import os

conf = json.load(open(sys.argv[1]))

## First, add all ethernet interfaces that are of type 1
existingifaces = []
if "ETHInterface" in conf['interfaces']:
    for interface in conf['interfaces']['ETHInterface']:
        existingifaces.append(interface['bind'])
else:
    conf['interfaces']['ETHInterface'] = []

for dev in os.listdir("/sys/class/net"):
    if not dev in existingifaces:
        # What is a good way to detect physical vs virtual devices? I highly doubt this is way is any good
        iftype =  open("/sys/class/net/%s/type" % dev).read().strip()
        if iftype == "1":
            print "Adding ETHInterface to %s" % dev
            conf['interfaces']['ETHInterface'].append({"connectTo": {}, "bind": dev, "beacon": 2})
        else:
            print "Ignoring %s because it is a virtual interface or something weird (%s)" % (dev, iftype)
    else:
        print "ETHInterface already set up for %s" % dev

# Next update the config based on the settings in settings/config.json (or ./config.json.dist if that fails)
try:
    conf.update(json.load(open("/tmp/settings/config.json")))
except ValueError, IOError:
    conf.update(json.load(open("/tmp/settings/config.json.dist")))

# Finally, add any UDP peers that may be in /tmp/settings/peers
try:
    peers = json.load(open("/tmp/settings/peers.json"))
    for peer in peers:
        conf['interfaces']['UDPInterface'][0]['connectTo'][peer] = peers[peer]
except ValueError as e:
    print "Failed to add %s (%s)" % (peerfile, e)
save = open(sys.argv[1], "w")
save.write(json.dumps(conf, sort_keys=True, indent=4, separators=(',', ': ')))
save.close()
