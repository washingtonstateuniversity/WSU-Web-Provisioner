#!/bin/bash
#
# Install Java SDK
curl -L --cookie "oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u101-b13/jdk-8u101-linux-x64.tar.gz -o jdk-8-linux-x64.tar.gz
tar -xvf jdk-8-linux-x64.tar.gz

sudo mkdir -p /usr/lib/jvm
rm -rf /usr/lib/jvm/jdk1.8.0-old
mv /usr/lib/jvm/jdk1.8.0 /usr/lib/jvm/jdk1.8.0-old
sudo mv ./jdk1.8.0_101 /usr/lib/jvm/jdk1.8.0

sudo update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/jdk1.8.0/bin/java" 1
sudo update-alternatives --install "/usr/bin/javac" "javac" "/usr/lib/jvm/jdk1.8.0/bin/javac" 1
sudo update-alternatives --install "/usr/bin/javaws" "javaws" "/usr/lib/jvm/jdk1.8.0/bin/javaws" 1

sudo chmod a+x /usr/bin/java
sudo chmod a+x /usr/bin/javac
sudo chmod a+x /usr/bin/javaws
sudo chown -R root:root /usr/lib/jvm/jdk1.8.0

rm jdk-8-linux-x64.tar.gz
