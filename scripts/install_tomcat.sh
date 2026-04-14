#!/bin/bash
# Evitar interrupciones en la instalación
export DEBIAN_FRONTEND=noninteractive

# 1. Requisito tarea: Evitar reinicios interactivos
sed -i "s/#\$nrconf{kernelhints} = -1;/\$nrconf{kernelhints} = -1;/g" /etc/needrestart/needrestart.conf

# 2. Instalar Java 17
apt-get update
apt-get install -y openjdk-17-jdk curl

# Creacion de usuario tomcat sin aceso a a linea de comando
sudo useradd -m -d /opt/tomcat -U -s /bin/false tomcat

# 3. Descargar e instalar Tomcat 11
VERSION="11.0.0-M20"
mkdir -p /opt/tomcat
curl -O https://archive.apache.org/dist/tomcat/tomcat-11/v$VERSION/bin/apache-tomcat-$VERSION.tar.gz
tar xzvf apache-tomcat-$VERSION.tar.gz -C /opt/tomcat --strip-components=1

# 4. REQUISITO TAREA: Permitir acceso externo (Corregido para no romper el XML)
# Configuracion de usuarios
sed -i '/<\/tomcat-users>/i \
<role rolename="manager-gui" />\
<user username="manager" password="manager_password" roles="manager-gui" />\
<role rolename="admin-gui" />\
<user username="admin" password="admin_password" roles="manager-gui,admin-gui" />' /opt/tomcat/conf/tomcat-users.xml


# Comentamos la Valve de seguridad para que permita IPs externas
sed -i '/<Valve /,/\/>/ s|<Valve||' /opt/tomcat/webapps/manager/META-INF/context.xml
sed -i '/<Valve /,/\/>/ s|<Valve||' /opt/tomcat/webapps/host-manager/META-INF/context.xml

# Dar permisos al user
sudo chown -R tomcat:tomcat /opt/tomcat/
sudo chmod -R u+x /opt/tomcat/bin

# 5. Crear servicio de Systemd
cat << EOF > /etc/systemd/system/tomcat.service
[Unit]
Description=Tomcat
After=network.target

[Service]
Type=forking

User=tomcat
Group=tomcat

Environment="JAVA_HOME=/usr/lib/jvm/java-1.17.0-openjdk-amd64"
Environment="JAVA_OPTS=-Djava.security.egd=file:///dev/urandom"
Environment="CATALINA_BASE=/opt/tomcat"
Environment="CATALINA_HOME=/opt/tomcat"
Environment="CATALINA_PID=/opt/tomcat/temp/tomcat.pid"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable tomcat
systemctl start tomcat

# 5. Dar permisos y arrancar
#chmod +x /opt/tomcat/bin/*.sh
#/opt/tomcat/bin/startup.sh