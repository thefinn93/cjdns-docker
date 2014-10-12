FROM ubuntu:trusty
RUN apt-get update
RUN apt-get install -y nodejs npm git build-essential python jq
ADD ./installcjdns.sh /tmp/installcjdns.sh
RUN /tmp/installcjdns.sh
ADD ./settings /tmp/settings
ADD ./editconf.py /opt/editconf.py
ADD ./makeconfig.sh /usr/bin/startcjdns

ENTRYPOINT ["/usr/bin/startcjdns"]
