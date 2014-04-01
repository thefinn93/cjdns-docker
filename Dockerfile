FROM ubuntu:saucy
RUN apt-get update
RUN apt-get install -y nodejs git build-essential python jq
ADD ./installcjdns.sh /tmp/installcjdns.sh
RUN /tmp/installcjdns.sh
ADD ./config.json.dist /tmp/config.json
ADD ./settings /tmp/settings
ADD ./startcjdns.sh /bin/startcjdns
ADD ./editconf.py /opt/editconf.py
ADD ./makeconfig.sh /tmp/makeconfig.sh
ENTRYPOINT /tmp/makeconfig.sh
CMD startcjdns
