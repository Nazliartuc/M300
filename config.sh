sudo su

#Konfiguration Firewall
#Rein kommende und Rusgehenden verbindungen ablehnen
sudo ufw default deny incoming
sudo ufw default deny outgoing

#https verbindung nach aussen erlauben
ufw allow out on enps03 to any port 80
ufw allow out on enps03 to any port 443

#mysql verbindung nach innen erlauben
sudo ufw allow in on enps03 to any port 8888

#Erlaube SSH verbindung nur von diesem Computer
sudo ufw allow in on enps03 from 127.0.0.1 to any port 2222

#Firewall aktivieren
sudo ufw enable

#mysql installation mit root passwort
sudo apt-get update
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password nSscVjjraPVQ6CEAkktL'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password nSscVjjraPVQ6CEAkktL'
sudo apt-get -y install mysql-server

#Erlaube mysql verbindung von 0.0.0.0
sudo sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf

#Erstelle nextclooud Benutzer; Datenbank erlaube alle berechtigung auf localhost
mysql -uroot -pnSscVjjraPVQ6CEAkktL -e "CREATE DATABASE nextcloud";
mysql -uroot -pnSscVjjraPVQ6CEAkktL -e "CREATE USER 'nextcloud'@'localhost' IDENTIFIED BY '6mYOGLPtvrqdx89WES6L'"
mysql -uroot -pnSscVjjraPVQ6CEAkktL -e "GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'localhost'"

#mysql neustarten
service mysql restart


sudo apt-get install apache2 libapache2-mod-php7.2 -y
sudo apt-get install php7.2-gd php7.2-json php7.2-mysql php7.2-curl php7.2-mbstring -y
sudo apt-get install php7.2-intl php-imagick php7.2-xml php7.2-zip -y

#Echo umleiten auf apache default conf
sed -i '8iRedirectMatch ^/$ /nextcloud/' /etc/apache2/sites-enabled/000-default.conf

#Nextcloud herunterladen und entzippen
cd /var/www/html
wget https://download.nextcloud.com/server/releases/nextcloud-15.0.5.tar.bz2 -O nextcloud.tar.bz2
tar -xjf nextcloud.tar.bz2

#Berechtigungen Setzen
chown -R www-data:www-data /var/www/html/nextcloud
chmod 750 /var/www/html/nextcloud -R

#tar Datei entfernen
rm -f -r nextcloud.tar.bz2

#Daten Ordner erstellen und rechte setzen
mkdir /Nextcloud
chown www-data:www-data /Nextcloud
chmod 750 /Nextcloud

#nextcloud apache Konfigurationen setzen
echo "Alias /nextcloud "/var/www/html/nextcloud/"

<Directory /var/www/html/nextcloud/>
  Options +FollowSymlinks
  AllowOverride All

 <IfModule mod_dav.c>
  Dav off
 </IfModule>

 SetEnv HOME /var/www/html/nextcloud
 SetEnv HTTP_HOME /var/www/html/nextcloud

</Directory>" > "/etc/apache2/sites-available/nextcloud.conf"

#nexloud Konfiguration freischalten
a2ensite nextcloud.conf

#Apache Server
service apache2 restart

#Nextcloud Konfigurieren
sudo -u www-data php /var/www/html/nextcloud/occ maintenance:install --database "mysql" --database-name "nextcloud" --database-user "nextcloud" --database-pass "6mYOGLPtvrqdx89WES6L" --database-host localhost --admin-user "admin" --admin-pass "Test1234" --data-dir "/Nextcloud"