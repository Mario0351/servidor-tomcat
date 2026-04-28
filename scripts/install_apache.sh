#!/bin/bash
sudo apt-get update
sudo apt-get install -y apache2

sudo a2enmod proxy
sudo a2enmod proxy_http

cat << EOF > /etc/apache2/sites-available/000-default.conf
<VirtualHost *:80>
    ProxyPreserveHost On
    
    ProxyPass / http://${tomcat_ip}:8080/
    ProxyPassReverse / http://${tomcat_ip}:8080/

    ErrorLog /var/log/apache2/error.log
    CustomLog /var/log/apache2/access.log combined
</VirtualHost>
EOF

sudo systemctl restart apache2