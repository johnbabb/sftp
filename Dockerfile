FROM debian:buster
MAINTAINER John Babb [triskelle.solutions]

# Steps done in one RUN layer:
# - Install packages
# - OpenSSH needs /var/run/sshd to run
# - Remove generic host keys, entrypoint generates unique keys
RUN apt-get update && \
    apt-get -y install openssh-server && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /var/run/sshd && \
    rm -f /etc/ssh/ssh_host_*key*

COPY files/sshd_config /etc/ssh/sshd_config
COPY files/create-sftp-user /usr/local/bin/
COPY files/entrypoint /

ENV LC_ALL C.UTF-8
EXPOSE 10000
EXPOSE 22

ENTRYPOINT ["/entrypoint"]


RUN echo "Acquire::GzipIndexes \"false\"; Acquire::CompressionTypes::Order:: \"gz\";" >/etc/apt/apt.conf.d/docker-gzip-indexes && \
	apt-get update && \
	apt-get install -y \
	wget \
	locales && \
	dpkg-reconfigure locales && \
	locale-gen C.UTF-8 && \
	/usr/sbin/update-locale LANG=C.UTF-8 && \
	wget http://www.webmin.com/jcameron-key.asc && \
	apt-key add jcameron-key.asc && \
	echo "deb http://download.webmin.com/download/repository sarge contrib" >> /etc/apt/sources.list && \
	echo "deb http://webmin.mirror.somersettechsolutions.co.uk/repository sarge contrib" >> /etc/apt/sources.list && \
	apt-get update && \
	apt-get install -y webmin && \
	apt-get clean




VOLUME ["/etc/webmin"]

CMD /usr/bin/touch /var/webmin/miniserv.log && /usr/sbin/service webmin restart && /usr/bin/tail -f /var/webmin/miniserv.log

