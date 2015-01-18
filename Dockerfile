FROM     ubuntu:14.04
MAINTAINER Bryce Gibson "bryce.gibson@unico.com.au"

RUN echo "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) main universe" > /etc/apt/sources.list
RUN apt-get update && apt-get upgrade -y

RUN apt-get install -y vim freeradius freeradius-utils

RUN apt-get clean

ADD ./clients.conf /etc/freeradius/clients.conf
ADD ./users /etc/freeradius/users

ADD ./start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

VOLUME ["/etc/freeradius/"]

EXPOSE 1812/udp
EXPOSE 1812/tcp

CMD /usr/local/bin/start.sh