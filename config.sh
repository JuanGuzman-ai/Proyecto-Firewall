#!/bin/bash

## Server Firewall
sudo -i
#Instalamos vim
yum update -y
yum install vim -y
#Detenemos NetworkManager
service NetworkManager stop
chkconfig NetworkManager off
#Configuramos la ip_forward
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
#Configuramos el firewall
systemctl start firewalld
systemctl enable firewalld
#Gestionamos las zonas
firewall-cmd --permanent --zone=dmz --add-interface=eth1
firewall-cmd --permanent --zone=internal --add-interface=eth2
firewall-cmd --reload
#Agregamos las reglas
firewall-cmd --direct --permanent --add-rule ipv4 nat POSTROUTING 0 -o eth2 -j MASQUERADE
firewall-cmd --direct --permanent --add-rule ipv4 filter FORWARD 0 -i eth1 -o eth2 -j ACCEPT
firewall-cmd --direct --permanent --add-rule ipv4 filter FORWARD 0 -i eth2 -o eth1 -m state --state RELATED,ESTABLISHED -j ACCEPT
#Agregamos servicio http a las zona dmz y el puerto
firewall-cmd --permanent --zone=dmz --add-service=http                                                                                                                                                             
firewall-cmd --zone=dmz --add-port=8080/tcp --permanent                                                                                                                                                            
#Añadimos el redirect al servidor streama                                                                                                                                                                          
firewall-cmd --zone="dmz" --add-forward- port=8080:proto=tcp:toport=8080:toaddr=192.168.50.4 --permanent                                                                                                           
firewall-cmd --zone="internal" --add-forward- port=8080:proto=tcp:toport=8080:toaddr=192.168.50.4 --permanent                                                                                                      
firewall-cmd --reload

## Server Streama
sudo -i
#Instalamos las librerias necesarias
yum update -y
yum install vim wget httpd mod_ssl -y
#Instalamos java
yum install java-1.8.0-openjdk-devel -y
#Descargamos Streama War
wget https://github.com/streamaserver/streama/releases/download/v1.6.1/streama-1.6.1.war
#Creamos la carpeta streama y movemos la descarga .war
mkdir /opt/streama
mv streama-1.6.1.war /opt/streama/streama.war
#Creamos la carpeta media en el directorio creado anterio y le damos privilegios
mkdir /opt/streama/media
chmod 664 /opt/streama/media
chmod 777 /etc/systemd/system
#Agregamos las siguientes lineas al servicios de streama
echo "[Unit]
Description=Streama Server
After=syslog.target
After=network.target

[Service]                                                                                                                                                                                                          
User=root                                                                                                                                                                                                          
Type=simple                                                                                                                                                                                                        
ExecStart=/bin/java -jar /opt/streama/streama.war                                                                                                                                                                  
Restart=always                                                                                                                                                                                                     
StandardOutput=syslog                                                                                                                                                                                              
StandardError=syslog                                                                                                                                                                                               
SyslogIdentifier=Streama                                                                                                                                                                                           
                                                                                                                                                                                                                   
[Install]                                                                                                                                                                                                          
WantedBy=multi-user.target" >> /etc/systemd/system/streama.service                                                                                                                                                 
#Dejamos funcionando el servicios de streama y el servicios httpd                                                                                                                                                  
systemctl start streama                                                                                                                                                                                            
systemctl enable streama                                                                                                                                                                                           
systemctl start httpd                                                                                                                                                                                              
systemctl enable httpd 
