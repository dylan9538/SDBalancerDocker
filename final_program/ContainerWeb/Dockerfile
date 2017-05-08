FROM httpd
MAINTAINER Dylan Torres

##Se bajan los recursos confd
ADD https://github.com/kelseyhightower/confd/releases/download/v0.10.0/confd-0.10.0-linux-amd64 /usr/local/bin/confd
ADD files/start.sh /start.sh

RUN chmod +x /usr/local/bin/confd
RUN chmod +x /start.sh

ADD files/confd /etc/confd

CMD ["/start.sh"]


