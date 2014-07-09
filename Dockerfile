# Builds OTRS-3.2 with MySQL in single container - suitable for development
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

FROM centos:6.4

# install SSH
RUN yum install -y openssh-server openssh-clients passwd
RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key && \
    ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key 
RUN sed -ri 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config && \
     echo 'root:changeme' | chpasswd

# install MySQL
RUN yum install -y mysql-server mysql
# tune MySQL for OTRS
RUN sed -i.bak '/\[mysqld\]/amax_allowed_packet=32m' /etc/my.cnf
RUN sed -i.bak '/\[mysqld\]/aquery_cache_size=10m' /etc/my.cnf
# install Apache 
RUN yum install -y httpd mod_ssl
# install OTRS requirements
RUN yum install -y perl-core perl-Crypt-SSLeay mod_perl procmail mailx \
         perl-DBI perl-DBD-MySQL perl-TimeDate perl-Net-DNS \
         perl-IO-Socket-SSL \
         perl-Convert-ASN1 perl-XML-Parser \
         perl-GraphViz \
         perl-GDGraph perl-GDTextUtil  \
         perl-JSON-XS perl-LDAP perl-PDF-API2 perl-SOAP-Lite \
         perl-Text-CSV_XS perl-Crypt-PasswdMD5 perl-Digest-SHA \
         perl-Devel-Symdump \
         perl-Mail-IMAPClient perl-YAML-LibYAML \
         perl-MailTools cronie
# OTRS 
RUN rpm -ivh http://ftp.otrs.org/pub/otrs/RPMS/rhel/6/otrs-3.2.5-01.noarch.rpm

# supervisor
RUN rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
RUN yum install -y python-pip && pip install pip --upgrade
RUN pip install supervisor
ADD supervisord.conf /etc/

# MySQL bootstrap - database otrs/ password otrs
ADD setup-otrs /opt/setup-otrs
RUN /usr/bin/mysql_install_db --datadir=/var/lib/mysql --user=mysql
RUN touch /etc/sysconfig/network
RUN /etc/init.d/mysqld start && \
    mysql -u root mysql < /opt/setup-otrs/create_otrs_db.sql && \
    mysql -u root otrs < /opt/setup-otrs/otrs_tables.sql && \
    /opt/setup-otrs/set-config-pm-value.pl Database=otrs \
      DatabaseUser=otrs DatabasePw=otrs DatabaseHost=127.0.0.1 SecureMode=1; \
    /opt/otrs/bin/otrs.SetPassword.pl root@localhost root; \
    /opt/otrs/bin/otrs.PackageManager.pl -a install \
       -p http://ftp.otrs.org/pub/otrs/packages/:FAQ-2.2.3.opm; \
    /opt/otrs/bin/otrs.PackageManager.pl -a install \
       -p http://ftp.otrs.org/pub/otrs/packages/:Support-1.4.5.opm; \
    /opt/otrs/bin/otrs.PackageManager.pl -a install \
       -p http://ftp.otrs.org/pub/otrs/itsm/bundle32/:ITSM-3.2.3.opm; \
    /etc/init.d/mysqld stop
RUN chown -R otrs:apache /opt/otrs
RUN chmod -R g+rwX /opt/otrs

# export SSH port
EXPOSE 22
# export Apache ports
EXPOSE 80 443
CMD ["supervisord", "-n"]

