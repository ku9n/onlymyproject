#!/bin/bash
sudo apt-get update
sudo apt upgrade -y
sudo apt install default-jdk -y
sudo groupadd tomcat
sudo useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat
cd /tmp
curl -O http://apache.volia.net/tomcat/tomcat-9/v9.0.31/bin/apache-tomcat-9.0.31.tar.gz
sudo mkdir /opt/tomcat
cd /opt/tomcat
sudo tar xpvf /tmp/apache-tomcat-9.0.31.tar.gz --strip-components=1 -C /opt/tomcat
sudo chgrp -R tomcat /opt/tomcat
sudo chmod -R g+r conf
sudo chmod g+x conf
sudo chown -R tomcat webapps/ work/ temp/ logs/
sudo cp /tmp/tomcat.service /etc/systemd/system/tomcat.service
sudo cp /tmp/context.xml /opt/tomcat/webapps/host-manager/META-INF/context.xml
sudo cp /tmp/context.xml /opt/tomcat/webapps/manager/META-INF/context.xml
sudo cp /tmp/tomcat-users.xml /opt/tomcat/conf/tomcat-users.xml
sudo update-java-alternatives -l
sudo systemctl daemon-reload
sudo systemctl start tomcat
sudo ufw allow 8080
sudo systemctl enable tomcat
cd /tmp
wget http://mirrors.jenkins.io/war-stable/latest/jenkins.war
sudo cp -rv jenkins.war /opt/tomcat/webapps
cd /opt/tomcat
sudo mkdir .jenkins
sudo chown tomcat:nogroup .jenkins
sudo systemctl restart tomcat
