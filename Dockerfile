FROM ubuntu:14.04
MAINTAINER Peter Rosell "peter.rosell@gmail.com"

# install freeradius and yubico pam module
RUN echo "deb http://ppa.launchpad.net/yubico/stable/ubuntu trusty main" >> /etc/apt/sources.list && \
 echo "deb-src http://ppa.launchpad.net/yubico/stable/ubuntu trusty main " >> /etc/apt/sources.list && \
 apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 32CBA1A9 && \
 apt-get update && apt-get upgrade -y && \
 DEBIAN_FRONTEND=noninteractive apt-get install -y nano freeradius freeradius-utils libpam-yubico && \
 apt-get clean autoclean && apt-get autoremove -y && rm -rf /var/lib/{apt,dpkg,cache,log}/



# Config pam to use yubico and local passwd
RUN echo "auth required pam_yubico.so id=16 debug authfile=/etc/yubikey_mappings" > /tmp/radiusd && \
 echo "auth required pam_unix.so use_first_pass" >> /tmp/radiusd && \
 mv /tmp/radiusd /etc/pam.d/radiusd

# radiusd must run as root to be able to do pam calls
RUN sed -i 's/user = .*/user = root/' /etc/freeradius/radiusd.conf && \
 sed -i 's/group = .*/group = root/' /etc/freeradius/radiusd.conf

# Activate pam support for freeradius
RUN sed -i 's/#.*pam/pam/' /etc/freeradius/sites-enabled/default
RUN sed -i 's/#.*pam/pam/' /etc/freeradius/sites-enabled/inner-tunnel

# Change to use pam when Auth-Type PAP is used in the inner-tunnel
# If this is line is commented out the users-file will be used instead of ṔAM
RUN sed -i 's/\t\tpap/\t\tpam/' /etc/freeradius/sites-enabled/inner-tunnel


# Add mapping file for user->yubikey ID for OTP (one-time-password)
ADD ./yubikey_mappings /etc/yubikey_mappings

#create local test user from PAM
RUN useradd admin && echo "admin:docAdmin" | chpasswd
RUN useradd bob && echo "bob:userBob" | chpasswd

ADD ./clients.conf /etc/freeradius/clients.conf
ADD ./users /etc/freeradius/users

ADD ./start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

VOLUME ["/etc/freeradius/"]

EXPOSE 1812/udp
EXPOSE 1812/tcp

CMD /usr/local/bin/start.sh
