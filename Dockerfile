# Builds OTRS-2.4.6 with MySQL in single container - suitable for development
# and testing of deployments

# Based on https://github.com/dockerfiles/centos-lamp

# To build OTRS image use:
#    sudo docker build -t MY_OTRS_IMAGE .
# To run
#    sudo docker run -P -d --name=MY_OTRS_INSTANCE MY_OTRS_IMAGE
# Later run 
#    sudo docker ps
# To see external ports mapping (typically 4915X)
# OTRS URL: http://YOUR_HOST:PORT/otrs/index.pl
# OTRS admin login/password: root@localhost/root
# SSH  login/password: root/changeme

FROM centos:centos6

# install required packages
RUN yum install -y openssh-server openssh-clients passwd tar \
               mysql-server mysql \
               httpd mod_ssl && \
 rpm -ivh \
 http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm && \
 yum install -y perl-core perl-Crypt-SSLeay mod_perl procmail mailx \
         perl-DBI perl-DBD-MySQL perl-TimeDate perl-Net-DNS \
         perl-IO-Socket-SSL \
         perl-Convert-ASN1 perl-XML-Parser \
         perl-GraphViz \
         perl-GDGraph perl-GDTextUtil  \
         perl-JSON-XS perl-LDAP perl-PDF-API2 perl-SOAP-Lite \
         perl-Text-CSV_XS perl-Crypt-PasswdMD5 perl-Digest-SHA \
         perl-Devel-Symdump \
         perl-Mail-IMAPClient perl-YAML-LibYAML \
         perl-MailTools cronie && \
 rpm -ivh http://ftp.otrs.org/pub/otrs/RPMS/fedora/4/otrs-2.4.6-01.noarch.rpm && \
 yum install -y python-pip && pip install pip --upgrade && \
 pip install supervisor

# bootstrap otrs
ADD setup-otrs /opt/setup-otrs
RUN /opt/setup-otrs/bootstrap_otrs.sh
ADD supervisord.conf /etc/

# export SSH port
EXPOSE 22
# export Apache ports
EXPOSE 80 443
CMD ["supervisord", "-n"]

