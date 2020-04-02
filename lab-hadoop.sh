# update system
yum clean all
yum -y install epel-release
yum -y update

# install java and wget
yum install -y wget java
java -version

# config ip
vi /etc/hosts

-------------------------------------
192.168.0.x edge.ts.com edge

192.168.0.x master1.ts.com master1
192.168.0.x master2.ts.com master2

192.168.0.x worker1.ts.com worker1
192.168.0.x worker2.ts.com worker2
192.168.0.x worker3.ts.com worker3
-------------------------------------

# set hostname should once per cmd

hostnamectl set-hostname edge.ts.com

ssh master1 hostnamectl set-hostname master1.ts.com
ssh master2 hostnamectl set-hostname master2.ts.com

ssh worker1 hostnamectl set-hostname worker1.ts.com
ssh worker2 hostnamectl set-hostname worker2.ts.com
ssh worker3 hostnamectl set-hostname worker3.ts.com

# create hosts file on /home/ 
cd /home/
vi hosts

---------
master1
master2
worker1
worker2
worker3
---------

# install pdsh - can run multiple remote commands in parallel from single remote host.
yum install -y pdsh

#However, you may have issue about permission denied when run pdsh to remote on the other server
#Use on main server is enough and run once per cmd
ssh-keygen

cat ~/.ssh/id_rsa.pub | ssh master1 'cat >> .ssh/authorized_keys'
cat ~/.ssh/id_rsa.pub | ssh master2 'cat >> .ssh/authorized_keys'

cat ~/.ssh/id_rsa.pub | ssh worker1 'cat >> .ssh/authorized_keys'
cat ~/.ssh/id_rsa.pub | ssh worker2 'cat >> .ssh/authorized_keys'
cat ~/.ssh/id_rsa.pub | ssh worker3 'cat >> .ssh/authorized_keys'

#test pdsh one target node again - dir is /home/
pdsh -w master1 hostname 
#master1: master1.ts.com -it's working fine

pdsh -w ^hosts hostname
#worker3: worker3.ts.com
#master1: master1.ts.com
#worker2: worker2.ts.com
#worker1: worker1.ts.com
#master2: master2.ts.com

#Create dir /root/bin along with script file 'pscp
mkdir /root/bin
cd /root/bin
vi pscp

-------------------------------
#!/bin/sh
for i in `cat /root/hosts`
do
scp $1 ${i}:$1
done
-------------------------------

#config permission setting to exececute
chmod +x /root/bin/pscp 
#from -rw-r--r--. to -rwxr-xr-x.

#Send /etc/hosts to all nodes
pscp /etc/hosts

#Optional : you can check /etc/hosts which the results is same
ssh master1 cat /etc/hosts
ssh master2 cat /etc/hosts
ssh worker1 cat /etc/hosts
ssh worker2 cat /etc/hosts 
ssh worker3 cat /etc/hosts

#install MariaDB
yum install -y mariadb-server
systemctl enable mariadb
systemctl start mariadb

#setup MySQL JDBC
yum install -y bash-completion-extras
wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.46.tar.gz
tar xvf mysql-connector-java-5.1.46.tar.gz
mkdir -p /usr/share/java
cp mysql-connector-java-5.1.46/mysql-connector-java-5.1.46.jar /usr/share/java
ln -sf /usr/share/java/mysql-connector-java-5.1.46.jar /usr/share/java/mysql-connector-java.jar
#ln คือ ใช้ในการสร้าง link เชื่อมโยงกันระหว่าง file

# Cloudera Enterprise 6 Installation
# Cloudera Manager 6.3 Installation Guide
# https://www.cloudera.com/documentation/enterprise/6/6.3/topics/installation.html

wget http://203.150.243.131/repos/cm6/6.3.1/cloudera-manager.repo -P /etc/yum.repos.d/
vi /etc/yum.repos.d/cloudera-manager.repo

------------------------------------------------------------------
baseurl=http://203.150.243.131/repos/cm6/6.3.1/
gpgkey=http://203.150.243.131/repos/cm6/6.3.1/RPM-GPG-KEY-cloudera
------------------------------------------------------------------

#Install Cloudera Manager
yum install -y oracle-j2sdk1.8 cloudera-manager-server

#Creating Databases (MariaDB) for Cloudera Software
#create db 'scm', 'amon' , 'rman', 'hue', 'metastore', 'sebtry', 'nav', 'navms', 'oozie'
mysql

CREATE DATABASE scm DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
GRANT ALL ON scm.* TO 'scm'@'%' IDENTIFIED BY 'password';
grant all on scm.* to 'scm'@'localhost' identified by 'password';
grant all on scm.* to 'scm'@'edge.ts.com' identified by 'password';

CREATE DATABASE amon DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
GRANT ALL ON amon.* TO 'amon'@'%' IDENTIFIED BY 'password';
grant all on amon.* to 'amon'@'localhost' identified by 'password';
grant all on amon.* to 'amon'@'edge.ts.com' identified by 'password';

CREATE DATABASE rman DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
GRANT ALL ON rman.* TO 'rman'@'%' IDENTIFIED BY 'password';
grant all on rman.* to 'rman'@'localhost' identified by 'password';
grant all on rman.* to 'rman'@'edge.ts.com' identified by 'password';

CREATE DATABASE hue DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
GRANT ALL ON hue.* TO 'hue'@'%' IDENTIFIED BY 'password';
grant all on hue.* to 'hue'@'localhost' identified by 'password';
grant all on hue.* to 'hue'@'edge.ts.com' identified by 'password';

CREATE DATABASE metastore DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
GRANT ALL ON metastore.* TO 'hive'@'%' IDENTIFIED BY 'password';
grant all on metastore.* to 'hive'@'localhost' identified by 'password';
grant all on metastore.* to 'hive'@'edge.ts.com' identified by 'password';

CREATE DATABASE sentry DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
GRANT ALL ON sentry.* TO 'sentry'@'%' IDENTIFIED BY 'password';
grant all on sentry.* to 'sentry'@'localhost' identified by 'password';
grant all on sentry.* to 'sentry'@'edge.ts.com' identified by 'password';

CREATE DATABASE nav DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
GRANT ALL ON nav.* TO 'nav'@'%' IDENTIFIED BY 'password';
grant all on nav.* to 'nav'@'localhost' identified by 'password';
grant all on nav.* to 'nav'@'edge.ts.com' identified by 'password';

CREATE DATABASE navms DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
GRANT ALL ON navms.* TO 'navms'@'%' IDENTIFIED BY 'password';
grant all on navms.* to 'navms'@'localhost' identified by 'password';
grant all on navms.* to 'navms'@'edge.ts.com' identified by 'password';

CREATE DATABASE oozie DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
GRANT ALL ON oozie.* TO 'oozie'@'%' IDENTIFIED BY 'password';
grant all on oozie.* to 'oozie'@'localhost' identified by 'password';
grant all on oozie.* to 'oozie'@'edge.ts.com' identified by 'password';

exit;

#List all dbs
mysql
show databases;






