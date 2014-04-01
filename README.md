# cjdns-docker

This is mostly for the purposes of me playing with docker. Use at your own
risk.

# Usage
For a simple image, just run:

```bash
$ docker build -t cjdns https://github.com/thefinn93/docker
$ docker run --privileged cjdns
```

The `--privileged` allows it to use special things, specifically the tun device
that cjdns needs to do it's magic. By default, it will configure your cjdns
instance to auto-peer over the ETHInterface with anyone it can find. On my
system, it seems that all the docker containers have the same MAC (same as the
host in fact), which makes none of that work. At least not yet. I'll
investigate this more later.

# Advanced
If you want to add UDP peers, stick them in `settings/peers.json`. Format is:
```json
{
    "172.17.42.1:59249": {
        "password": "yup",
        "publicKey": "4upjugvc9rmtw08uy61tg17zm66wtxswxsfbr2z30fc9urtdvnm0.k"
    },
    "123.444.55.22:13333" {
        "password": "supa secure password",
        "publicKey": "ThisIsTotallyMyPublicKeyGuies.k"
    }
}
```

Overriding other cjdns options (for example, setting logging to stdout) can be
done with a file called `config.json` (also in the settings directory). This
will replace any values in cjdroute.conf. See `settings/config.json.dist` for
an example. Note that the `.dist` file is used if no `config.json` file is
found.

# Todo:
* functional ETH autopeering
* expose admin interface maybe?
