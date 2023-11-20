#!/bin/bash
# install postgres
apt install postgresql postgresql-contrib -y



# install zabbix 
wget https://repo.zabbix.com/zabbix/6.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.4-1+ubuntu22.04_all.deb
dpkg -i zabbix-release_6.4-1+ubuntu22.04_all.deb
apt update

apt install zabbix-server-pgsql zabbix-frontend-php php8.1-pgsql zabbix-apache-conf zabbix-sql-scripts zabbix-agent -y

# sudo -u postgres createuser --pwprompt zabbix
# sudo -u postgres createdb -O zabbix zabbix
sudo -u postgres psql -q -c "CREATE ROLE zabbix WITH PASSWORD 'zabbix' LOGIN;"
sudo -u postgres psql -q -c "CREATE DATABASE zabbix WITH OWNER zabbix;"


zcat /usr/share/zabbix-sql-scripts/postgresql/server.sql.gz | sudo -u zabbix psql zabbix

# configure zabbix server
cat >> /etc/zabbix/zabbix_server.conf <<CONF
DBName=zabbix
DBPassword=zabbix
CONF

# configure zabbix web server
cat > /etc/zabbix/web/zabbix.conf.php <<PHP
<?php
// Zabbix GUI configuration file.

\$DB['TYPE']     = 'POSTGRESQL';
\$DB['SERVER']   = '127.0.0.1';
\$DB['PORT']     = '0';
\$DB['DATABASE'] = 'zabbix';
\$DB['USER']     = 'zabbix';
\$DB['PASSWORD'] = 'zabbix';

// Schema name. Used for IBM DB2 and PostgreSQL.
\$DB['SCHEMA'] = '';

\$ZBX_SERVER_NAME = 'zabbix_packer_ubuntu';

\$IMAGE_FORMAT_DEFAULT = IMAGE_FORMAT_PNG;
?>
PHP


# restart and enable zabbix
systemctl restart zabbix-server zabbix-agent apache2
systemctl enable zabbix-server zabbix-agent apache2


# SERVER_IP = ip addr show ens33 | grep "inet " | awk '{print $2}' | cut -d/ -f1
export SERVER_IP="$(ip addr show ens33 | grep "inet " | awk '{print $2}' | cut -d/ -f1)"

echo "http://${SERVER_IP}/zabbix"