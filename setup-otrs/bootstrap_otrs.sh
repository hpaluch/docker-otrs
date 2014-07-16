#!/bin/bash

set -e

ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key
ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key
sed -ri 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config
echo 'root:changeme' | chpasswd


sed -i.bak '/\[mysqld\]/amax_allowed_packet=32m' /etc/my.cnf && \
    sed -i.bak '/\[mysqld\]/aquery_cache_size=10m' /etc/my.cnf

/usr/bin/mysql_install_db --datadir=/var/lib/mysql --user=mysql
# Workaround for some versions of /etc/init.d/mysqld
touch /etc/sysconfig/network
/etc/init.d/mysqld start
mysql -u root mysql < /opt/setup-otrs/create_otrs_db.sql
mysql -u root otrs < /opt/setup-otrs/otrs_tables.sql
# avoid SysLog and /dev/log errors
/opt/setup-otrs/set-config-pm-value.pl LogModule=Kernel::System::Log::File \
      LogModule::LogFile=/opt/otrs/var/tmp/otrs.log
/opt/setup-otrs/set-config-pm-value.pl Database=otrs \
      DatabaseUser=otrs DatabasePw=otrs DatabaseHost=127.0.0.1 SecureMode=1
/opt/otrs/bin/otrs.setPassword root@localhost root
/opt/otrs/bin/opm.pl -a install \
       -p http://ftp.otrs.org/pub/otrs/packages/:FAQ-1.6.5.opm
/opt/otrs/bin/opm.pl -a install \
       -p http://ftp.otrs.org/pub/otrs/packages/:Support-1.0.95.opm
for i in GeneralCatalog-1.3.2.opm ITSMCore-1.3.2.opm ITSMConfigurationManagement-1.3.2.opm ITSMIncidentProblemManagement-1.3.1.opm ITSMServiceLevelManagement-1.3.2.opm ImportExport-1.3.2.opm
do
/opt/otrs/bin/opm.pl -a install \
       -p http://ftp.otrs.org/pub/otrs/itsm/packages13/:$i
done
/etc/init.d/mysqld stop
chown -R otrs:apache /opt/otrs
chmod -R g+rwX /opt/otrs
ls -l /
exit 0

