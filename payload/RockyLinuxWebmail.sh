#!/bin/bash
set -e
Release="Thu 30 Oct 2025 17:07:37 MDT"

#################################################################
# Change these values for your mail server
# These values are passed in from payload.sh
export MX_HOST=${MX_HOST-"mail"}
export MX_DOMAIN=${MX_DOMAIN-"SiliconTao.com"}
export COUNTRY=${COUNTRY-"CA"}
export STATE=${STATE-"Saskatchewan"}
export LOCATION=${LOCATION-"Regina"}
export ORGANIZATION=${ORGANIZATION-"Silicon Tao"}
export ORG_UNIT=${ORG_UNIT-"IT Department"}
export COMMON_NAME=${MX_DOMAIN}
export ENVIRONMENT=${ENVIRONMENT-"DEV"} # Set this value to DEV to generate weak passwords for accounts.
export EMAIL_ACCOUNTS=${EMAIL_ACCOUNTS-"sam bill lisa tammy"}
export ADMIN_IP=${ADMIN_IP-"0.0.0.0/0"}
#################################################################

hostnamectl set-hostname ${MX_HOST}.${MX_DOMAIN}
echo "127.0.0.1 $(hostname -s) $(hostname -f)" >>/etc/hosts
echo "::1 $(hostname -s) $(hostname -f)" >>/etc/hosts

# The root user has an ID value of 0.
# Any ID value that is not 0 is not root.
[[ $(id -u) -ne 0 ]] && {
  echo "Please run this script as root" >&2
  echo "sudo $0" >&2
  exit 6
}

LAST_SECTION=
source $(dirname $0)/lib.sh
Header "Rocky Linux Webmail setup"
Header $Release

Header "First Step, Remove And Update"
dnf erase httpd httpd-core httpd-tools || :
dnf check-update || :
dnf -y upgrade || :

Header "Packages"
dnf -y install net-tools tar vim nc

Header "Database"
dnf -y install mariadb mariadb-server
systemctl enable mariadb.service
systemctl start mariadb.service

# To perform a non-interactive version of "mysql_secure_installation"
# https://stackoverflow.com/a/27759061/3850804
# We may do this later.
# # Make sure that NOBODY can access the server without a password
# mysql -e "UPDATE mysql.user SET Password = PASSWORD('CHANGEME') WHERE User = 'root'"
# # Kill the anonymous users
# mysql -e "DROP USER ''@'localhost'"
# # Because our hostname varies we'll use some Bash magic here.
# mysql -e "DROP USER ''@'$(hostname)'"
# # Kill off the demo database
# mysql -e "DROP DATABASE test"
# # Make our changes take effect
# mysql -e "FLUSH PRIVILEGES"
# # Any subsequent tries to run queries this way will get access denied because lack of usr/pwd param

Header "Install PHP"
dnf -y install php-fpm php php-mysqlnd php-gd php-curl php-mbstring \
  php-xml php-zip php-intl php-pear php-devel php-ldap

Header "Install ImageMagick"
dnf config-manager --set-enabled crb
dnf -y install \
  https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm \
  https://dl.fedoraproject.org/pub/epel/epel-next-release-latest-9.noarch.rpm
dnf -y install ImageMagick ImageMagick-devel

# Install PHP library for ImageMagick
printf "\n" | pecl install imagick

echo "extension=imagick.so" >>/etc/php.ini

Header "FPM Service"
sed -i /etc/passwd -e 's/^apache:/www-data:/; s/:Aache:/:www-data:/'
sed -i /etc/group -e 's/^apache:/www-data:/'
sed -i /etc/shadow -e 's/^apache:/www-data:/'
sed -i /etc/gshadow -e 's/^apache:/www-data:/'
chown -R www-data:www-data /var/www
sed -i /etc/php-fpm.d/www.conf -e 's/^;listen.owner .*/listen.owner = www-data/'
sed -i /etc/php-fpm.d/www.conf -e 's/^;listen.group .*/listen.group = www-data/'
sed -i /etc/php-fpm.d/www.conf -e 's/^user = .*/user = www-data/'
sed -i /etc/php-fpm.d/www.conf -e 's/^group = .*/group = www-data/'

sed -i /etc/php-fpm.d/www.conf -e 's/^listen.acl_users/;listen.acl_users/'

# Grant the Nginx account access to the www-data group
usermod -a -G www-data nginx

systemctl enable php-fpm.service
systemctl start php-fpm.service

Header "Install Nginx"
dnf -y install nginx

cp /etc/nginx/nginx.conf{,_backup}
sed -i /etc/nginx/nginx.conf -e 's|\(.*\)root\(.* \)/.*;|\1root\2/var/www/html;|'

systemctl enable nginx.service
systemctl start nginx.service

Header "Firewall"
function removeProtocols {
  firewall-cmd --list-all --zone=$1 | grep services | cut -d: -f2 | while read -r LINE; do
    for i in $LINE; do
      firewall-cmd --zone=$1 --remove-service=$i
    done
  done
}

function ShowStatus {
  firewall-cmd --get-active-zones
  echo "------------------------------"
  firewall-cmd --list-all --zone=admin-ssh
  echo
  firewall-cmd --list-all --zone=public
}

dnf -y install firewalld || :
systemctl start firewalld.service
systemctl enable firewalld.service

CreateRollback.sh SEQ /etc/firewalld/
firewall-cmd --permanent --new-zone=admin-ssh
firewall-cmd --reload
removeProtocols admin-ssh
firewall-cmd --permanent --zone=admin-ssh --add-source=${ADMIN_IP}
firewall-cmd --permanent --zone=admin-ssh --set-target=ACCEPT
firewall-cmd --reload
firewall-cmd --zone=admin-ssh --add-port=22/tcp

removeProtocols public
firewall-cmd --zone=public --add-port=80/tcp
firewall-cmd --zone=public --add-port=443/tcp
firewall-cmd --runtime-to-permanent
firewall-cmd --reload
ShowStatus
CreateRollback.sh SEQ /etc/firewalld/

Header "RoundCube"
Header "Downloading RC"
RC="roundcubemail"
RCV="1.6.11"
GHR="github.com/roundcube"
DL="releases/download"
curl -L https://${GHR}/${RC}/${DL}/${RCV}/${RC}-${RCV}-complete.tar.gz >${RC}-${RCV}.tar.gz

# Create the web directory.
install -vd -o nginx -g nginx -m 750 /var/www
tar xfz ${RC}-${RCV}.tar.gz -C /var/www
rm -f ${RC}-${RCV}.tar.gz
rm -rf /var/www/{cgi-bin,html} || :
ln -s ${RC}-${RCV} /var/www/html
chown -R www-data:www-data /var/www

Header "SELinux"
VWRC=/var/www/${RC}-${RCV}
semanage fcontext --add --type httpd_log_t ${VWRC}/logs
restorecon -R -v ${VWRC}/logs/
semanage fcontext --add --type httpd_sys_rw_content_t ${VWRC}/temp
restorecon -R -v ${VWRC}/temp/
semanage fcontext -a -t httpd_sys_rw_content_t ${VWRC}/config
cd /var/www/html
semanage fcontext -C -l
cd -

Header "RoundCube Database"
PASS=$(dd if=/dev/random bs=1 count=100 2>/dev/null | sha256sum | cut -b 1-30)
echo "PASS=$PASS" >roundcube_db_password.txt

cat >/root/mysql_setup.sql <<@EOF
CREATE DATABASE roundcubemail CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER roundcube@localhost IDENTIFIED BY '${PASS}';
GRANT ALL PRIVILEGES ON roundcubemail.* TO roundcube@localhost;
SELECT User FROM mysql.user;
@EOF

cat /root/mysql_setup.sql | mysql
mysql roundcubemail </var/www/html/SQL/mysql.initial.sql

CONFIG=/var/www/html/config/config.inc.php
cp -v ${CONFIG}{.sample,}
sed -i ${CONFIG} -e "/db_dsnw/ s/pass/${PASS}/"
echo "\$config['username_domain'] = '${MX_DOMAIN}';" >>${CONFIG}

Header "PostFix"
dnf -y install postfix
CONF=/etc/postfix/master.cf
sed -i ${CONF} -e 's/^#submission/submission/'
sed -i ${CONF} -e '/^submission/,/^#smtps/ s/^#.*-o smtpd_sasl_auth_enable.*/ -o smtpd_sasl_auth_enable=yes/'

# Accept SMTP from all interfaces
CONF=/etc/postfix/main.cf
sed -i ${CONF} -e 's/^inet_interfaces.*/inet_interfaces = all/'

# Allow mail from ourselves at our domain because we set the hostname to be ${MX_HOST}.${MX_DOMAIN}
sed -i ${CONF} -e 's/^mydestination/#mydestination/'
sed -i ${CONF} -e '/^#mydestination.*mydomain$/ s/^#mydestination/mydestination/'

systemctl start postfix.service
systemctl enable postfix.service

Header "Cyrus SASL For Postfix Authentication"
dnf -y install cyrus-sasl-plain cyrus-sasl
systemctl start saslauthd.service
systemctl enable saslauthd.service

Header "Dovecot"
dnf -y install dovecot
CONF=/etc/dovecot/conf.d/10-auth.conf
sed -i ${CONF} -e 's/^#auth_username_format .*/auth_username_format = %n/'

CONF=/etc/dovecot/conf.d/10-mail.conf
sed -i ${CONF} -e 's|^#.*mail_location.*mbox.*INBOX.*var.*|mail_location = mbox:~/:INBOX=/var/spool/mail/%u|'
sed -i ${CONF} -e 's/^#mail_access_groups.*/mail_access_groups = mail/'

systemctl start dovecot.service
systemctl enable dovecot.service

netstat -naput | grep LISTEN

install -vd -m 750 /etc/dovecot/private/
openssl req -new -x509 -days 1000 -nodes -out "/etc/dovecot/dovecot.pem" -keyout "/etc/dovecot/private/dovecot.pem" \
  -subj "/C=${COUNTRY}/ST=${STATE}/L=${LOCATION}/O=${ORGANIZATION}/OU=${ORG_UNIT}/CN=${COMMON_NAME}"

Header "SMTP & IMAP firewall rules"

[[ $ENVIRONMENT == "PROD" ]] && {
  # No unencrypted ports in production, with the exception of port 80 to be used by Certbot.
  firewall-cmd --zone=public --add-port=587/tcp
  firewall-cmd --zone=public --add-port=993/tcp
} || {
  firewall-cmd --zone=public --add-port=25/tcp --add-port=587/tcp
  firewall-cmd --zone=public --add-port=143/tcp --add-port=993/tcp
}
firewall-cmd --list-ports
firewall-cmd --runtime-to-permanent

setsebool -P httpd_can_network_connect 1
setsebool -P httpd_can_sendmail 1
setsebool -P nis_enabled 1

Header "Add Admin Account"
DEFAULT_PASSWORD="password"
[[ $ENVIRONMENT == "PROD" ]] && {
  DEFAULT_PASSWORD=$(dd if=/dev/random bs=1 count=50 | md5sum | awk '{print $1}' | cut -b 1-12)
}
useradd -c "Admin" -s /bin/bash -d /home/admin admin
printf "${DEFAULT_PASSWORD}\n${DEFAULT_PASSWORD}\n" | passwd admin
sed -i /etc/aliases -e 's/^\(postmaster:.*\)root/\1admin/'
sed -i /etc/aliases -e 's/^\(abuse:.*\)root/\1admin/'

# Run this so these changes take effect
newaliases
Header "Add Email Accounts"
for i in $EMAIL_ACCOUNTS; do
  # BASH can uppercase the first letter using ${i^}
  useradd -c ${i^} -s /bin/bash -d /home/${i} ${i}
  printf "${DEFAULT_PASSWORD}\n${DEFAULT_PASSWORD}\n" | passwd ${i}
done
