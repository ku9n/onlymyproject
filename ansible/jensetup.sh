#!/bin/bash
cd /tmp
wget http://mirrors.jenkins.io/war-stable/latest/jenkins.war
sudo cp -rv jenkins.war /opt/tomcat/webapps
cd /opt/tomcat
sudo mkdir .jenkins
sudo chown tomcat:nogroup .jenkins
sudo systemctl restart tomcat
