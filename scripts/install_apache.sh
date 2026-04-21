#¡/bin/bash
sudo atp-get update
sudo atp-get install -y apache2

sudo a2enmod proxy
sudo a2enmod proxy_http

cat << EOF > /etc/apache2/sites-available/000-default.conf
<VirtualHost *:80>
    ProxyPreserveHost On
    
    ProxyPass / http://172.31.18.12:8080/
    ProxyPassReverse / http://172.31.18.12:8080/

    ErrorLog $${APACHE_LOG_DIR}/error.log
    CustomLog $${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

sudo systemctl restart apache2