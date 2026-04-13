#!/bin/bash
# Evitar interrupciones en la instalación
export DEBIAN_FRONTEND=noninteractive

# 1. Requisito tarea: Evitar reinicios interactivos
sed -i "s/#\$nrconf{kernelhints} = -1;/\$nrconf{kernelhints} = -1;/g" /etc/needrestart/needrestart.conf

# 2. Instalar Java 17
apt-get update
apt-get install -y openjdk-17-jdk curl

# 3. Descargar e instalar Tomcat 11
VERSION="11.0.0-M20"
mkdir -p /opt/tomcat
curl -O https://archive.apache.org/dist/tomcat/tomcat-11/v$VERSION/bin/apache-tomcat-$VERSION.tar.gz
tar xzvf apache-tomcat-$VERSION.tar.gz -C /opt/tomcat --strip-components=1

# 4. REQUISITO TAREA: Permitir acceso externo (Corregido para no romper el XML)
# Comentamos la Valve de seguridad para que permita IPs externas
sed -i '/<Valve /,/\/>/ s|<Valve||' /opt/tomcat/webapps/manager/META-INF/context.xml
sed -i '/<Valve /,/\/>/ s|<Valve||' /opt/tomcat/webapps/host-manager/META-INF/context.xml

# 5. Dar permisos y arrancar
chmod +x /opt/tomcat/bin/*.sh
/opt/tomcat/bin/startup.sh