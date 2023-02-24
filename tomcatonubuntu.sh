#!/bin/bash
#Updating ubuntu, and installing openjdk-11-jdk
sudo apt update
sudo apt install openjdk-11-jdk

#Creating a System User called tomcat
sudo useradd -m -U -d /opt/tomcat -s /bin/false tomcat

#downloading Apatche TomCat 9.0.71 in /tmp folder
VERSION=9.0.71
wget https://www-eu.apache.org/dist/tomcat/tomcat-9/v${VERSION}/bin/apache-tomcat-${VERSION}.tar.gz -P /tmp

#extracting the .tar.gz file to /opt/tomcat
sudo tar -xf /tmp/apache-tomcat-${VERSION}.tar.gz -C /opt/tomcat/

#creating a symbolic link called latest, that points to the Tomcat installation directory:
sudo ln -s /opt/tomcat/apache-tomcat-${VERSION} /opt/tomcat/latest

#Changing the directory ownership of /opt/tomcat to user and group tomcat
sudo chown -R tomcat: /opt/tomcat

#Changing the permission of the shell scripts inside the Tomcat’s bin directory for it to be executable
#These scripts are used to start, stop and, otherwise manage the Tomcat instance
sudo sh -c 'chmod +x /opt/tomcat/latest/bin/*.sh'

#Copying the tomcat.service file from the jenkins workspace to the /etc/systemd/system/
sudo cp /var/lib/jenkins/workspace/training-iac /etc/systemd/system -u

#Notifying systemd that a new unit file has been added/exists 
sudo systemctl daemon-reload

#Enabling and starting the Tomcat service
sudo systemctl enable --now tomcat

#Checking the status of the Tomcat service
sudo systemctl status tomcat

#Configuring firewall (if present) to openup port 8080 to access TomCat server from outside of the network 
sudo ufw allow 8080/tcp

#Configuring TomCat serve's Web MAnagement intergace by overwriting tomcat-users.xml file at /opt/tomcat/latest/conf/tomcat-users.xml
sudo cp /var/lib/jenkins/workspace/training-iac/tomcat-users.xml /opt/tomcat/latest/conf -u

#Skipping the steps to modify the conext.xml file to allow access to the web interface of webapps/users or webapps/host-managers at
#/opt/tomcat/latest/webapps/manager/META-INF/context.xml and /opt/tomcat/latest/webapps/host-manager/META-INF/context.xml
 
#restarting the tomcat service
sudo systemctl restart tomcat

#NOW WE CAN TEST THE TOMCAT IN THE BROWSER USING 
http://<your_domain_or_IP_address>:8080

