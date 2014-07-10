
set -e
# install SSH
yum install -y openssh-server openssh-clients passwd && \
    ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key && \
    ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key && \
    sed -ri 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config && \
    echo 'root:changeme' | chpasswd

# install MySQL
yum install -y mysql-server mysql
# tune MySQL for OTRS
sed -i.bak '/\[mysqld\]/amax_allowed_packet=32m' /etc/my.cnf && \
    sed -i.bak '/\[mysqld\]/aquery_cache_size=10m' /etc/my.cnf
# install Apache 
yum install -y httpd mod_ssl
# install OTRS requirements
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
         perl-MailTools cronie

# supervisor
yum install -y python-pip && pip install pip --upgrade && \
    pip install supervisor
exit 0

