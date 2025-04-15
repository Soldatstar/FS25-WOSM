# wazuh with Virtualbox

**Installation**

1. Herunterladen des OVA: https://documentation.wazuh.com/current/deployment-options/virtual-machine/virtual-machine.html
2. Bridge Yellow im Lab
3. wazuh-user:wazuh
4. Configure ip address (see below)
5. Reboot
6. Web admin:admin

**Static IP4 config**

Open this file:

```bash
sudo nano /etc/sysconfig/network-scripts/ifcfg-eth0
```

Give static ip: 

```
DEVICE=eth0
ONBOOT=yes
TYPE=Ethernet
NM_CONTROLLED=no
IPADDR=172.16.0.5
NETMASK=255.255.255.0
GATEWAY=172.16.0.1
DNS1=10.51.2.232
DNS2=8.8.8.8
```

Enable interface eth0 again:

```bash
sudo ifdown eth0 && sudo ifup eth0
```

Delete ip from dhcp:

```bash
ip -4 addr show dev eth0 | awk '/inet / {print $2} | grep -v '^172\.16\.0\.5' | xargs -n 1 sudo ip addr del $1 dev eth0
```