FROM ubuntu:saucy
RUN apt-get update
RUN apt-get install -y nodejs git build-essential python jq
ADD ./startcjdns.sh /bin/startcjdns
ADD ./addeth.py /opt/addeth.py
ADD ./makeconfig.sh /tmp/makeconfig.sh
ADD ./installcjdns.sh /tmp/installcjdns.sh
RUN /tmp/installcjdns.sh
ENTRYPOINT /tmp/makeconfig.sh
CMD startcjdns
