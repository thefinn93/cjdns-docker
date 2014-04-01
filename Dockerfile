FROM ubuntu:saucy
RUN apt-get install -qy nodejs git build-essential
RUN cd /opt
RUN git clone https://github.com/cjdelisle/cjdns
RUN cd cjdns
RUN ./do
ADD ./startcjdns.sh /bin/startcjdns
ADD ./addeth.py /opt/addeth.py
CMD startcjdns
