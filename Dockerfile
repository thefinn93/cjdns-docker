FROM ubuntu:trusty
RUN apt-get update
RUN apt-get install -y nodejs git build-essential python jq
ADD ./installcjdns.sh /tmp/installcjdns.sh
RUN /tmp/installcjdns.sh
ADD ./settings /tmp/settings
ADD ./editconf.py /opt/editconf.py
ADD ./makeconfig.sh /usr/bin/startcjdns

EXPOSE 11234/udp
ENTRYPOINT ["/usr/bin/startcjdns"]
