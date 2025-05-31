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

**Install docker**

```bash
sudo dnf update
sudo dnf install docker
sudo systemctl start docker
sudo systemctl enable docker
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

**Wazuh Docker Listener**

```bash
python3 --version
sudo apt update
sudo apt install python3-pip
sudo pip3 install docker==7.1.0 urllib3==1.26.20 requests==2.32.2 --break-system-packages
sudo nano /var/ossec/etc/ossec.conf
sudo usermod -aG docker wazuh
```

```
<wodle name="docker-listener">
  <disabled>no</disabled>
</wodle>
```


```bash
sudo systemctl restart wazuh-agent
sudo systemctl status wazuh-agent
```

```bash
for i in {1..20}; do sudo docker run --rm alpine echo "Hello from container"; done
```
