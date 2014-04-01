CJDROUTE="/opt/cjdns/cjdroute"
CJDROUTECONF="/etc/cjdroute.conf"

[ -d /dev/net ] || mkdir -p /dev/net
[ -c /dev/net/tun ] || mknod /dev/net/tun c 10 200

if ! [ -e $CJDROUTECONF ]; then
    ( # start a subshell to avoid side effects of umask later on 
        umask 077 # to create the file with 600 permissions without races
        $CJDROUTE --genconf | $CJDROUTE --cleanconf < /dev/stdin > $CJDROUTECONF
    ) # exit subshell; umask no longer applies
    echo 'WARNING: A new configuration file has been generated.'
fi

# Add all ethernet devices to the ETHInterface, enable auto-pering on them
opt/addeth.py $CJDROUTECONF

if grep -q 'noBackground' $CJDROUTECONF; then
    # Make sure NoBackground is set to something non-zero
    sed -i 's/"noBackground"\s*:\s*0/"noBackground":1/' $CJDROUTECONF
else
    # The config file was generated before noBackground was introduced,
    # so we'll have to add it! Hang on, this is a little tricky...
    # trim the last '}' and add the darned ',' to the config file
    conf="$(cat $CJDROUTECONF | tac | sed -e '0,/\}/{s/\}//}' -e '0,/\}/{s/\}/\}\,/}' | tac)"
    # can't redirect that right away because that clears the file BEFORE it's read
    echo "$conf" > $CJDROUTECONF
    # add the noBackground part
    echo '
"noBackground":1
}' >> $CJDROUTECONF
    echo 'WARNING: noBackground stanza was added to your config file.'
fi

$CJDROUTE < $CJDROUTECONF
