# daloRADIUS with Virtualbox

**Installation**

1. Herunterladen des OVA: https://sourceforge.net/projects/daloradius/files/daloradius/daloRADIUS%20VM/
2. Bridge Yellow im Lab 
3. Set IP 172.16.0.3 255.255.255.0 172.16.0.1 static
4. Reboot

**Login**

- Firefox: Searchbar about:config then security.tls.version.min to 1
- daloRADIUS Platform Login: first admin:admin, second administrator:radius
- PHPMyAdmin Login: root:daloradius 

**NAC for Switch**

```sql
use radius;
show tables;

insert into radgroupreply (groupname, attribute, op, value) values ('Vlan99', 'Tunnel-Type', '=', '13');
insert into radgroupreply (groupname, attribute, op, value) values ('Vlan99', 'Tunnel-Medium-Type', '=', '6');
insert into radgroupreply (groupname, attribute, op, value) values ('Vlan99', 'Tunnel-Private-Group-Id', '=', '99');

insert into radgroupreply (groupname, attribute, op, value) values ('Vlan10', 'Tunnel-Type', '=', '13');
insert into radgroupreply (groupname, attribute, op, value) values ('Vlan10', 'Tunnel-Medium-Type', '=', '6');
insert into radgroupreply (groupname, attribute, op, value) values ('Vlan10', 'Tunnel-Private-Group-Id', '=', '10');

insert into radgroupreply (groupname, attribute, op, value) values ('Vlan20', 'Tunnel-Type', '=', '13');
insert into radgroupreply (groupname, attribute, op, value) values ('Vlan20', 'Tunnel-Medium-Type', '=', '6');
insert into radgroupreply (groupname, attribute, op, value) values ('Vlan20', 'Tunnel-Private-Group-Id', '=', '20');

insert into radgroupreply (groupname, attribute, op, value) values ('Vlan30', 'Tunnel-Type', '=', '13');
insert into radgroupreply (groupname, attribute, op, value) values ('Vlan30', 'Tunnel-Medium-Type', '=', '6');
insert into radgroupreply (groupname, attribute, op, value) values ('Vlan30', 'Tunnel-Private-Group-Id', '=', '30');
```

1. Management>Nas>New Nas: IP 172.16.0.4, NAS Type cisco, NAS Secret Pasw0rd+ 
2. Management>User>Nwe User: damjan:damjan, Group: Vlan99


**Wazuh-Agent**

```bash
sudo WAZUH_MANAGER='172.16.0.5' dpkg -i ./wazuh-agent_4.12.0-1_i386.deb
/etc/init.d/wazuh-agent start
update-rc.d wazuh-agent defaults
```

**Node exporter**

```bash
tar -C /usr/local -xzf go1.18.linux-386.tar.gz
export PATH=$PATH:/usr/local/go/bin
tar xzf node_exporter.tar.gz 
cd node_exporter/
git checkout v1.3.1
go mod tidy
GOARCH=386 GOOS=linux go build -buildvcs=false -o node_exporter .
./node_exporter
```

Für den Reboot: 

```bash
nano /etc/rc.local

#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.
/root/node_exporter/node_exporter &

exit 0
```