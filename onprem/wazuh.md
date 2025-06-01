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

**Wazuh Active Response**

_Blocking SSH brute-force attack with Active Response_

```bash
sudo nano /var/ossec/etc/ossec.conf
sudo systemctl restart wazuh-manager
```

```
<ossec_config>
  <command>
    <name>firewall-drop</name>
    <executable>firewall-drop</executable>
    <timeout_allowed>yes</timeout_allowed>
  </command>

  <active-response>
    <disabled>no</disabled>
    <command>firewall-drop</command>
    <location>local</location>
    <rules_id>5763</rules_id>
    <timeout>180</timeout>
  </active-response>
</ossec_config>
```

Test: `sudo hydra -t 4 -l ubuntu-mirror -P passwd_list.txt 172.16.10.7 ssh`

Resultat in Wazuh: 
1. sshd: brute force trying to get access to the system. Authentication failed.
2. Host Blocked by firewall-drop Active Response

_Disabling a Linux user account with Active Response_

```bash
sudo nano /var/ossec/etc/rules/local_rules.xml
sudo nano /var/ossec/etc/ossec.conf
sudo systemctl restart wazuh-manager
```

local_rules.xml

```
<group name="pam,syslog,">
  <rule id="120100" level="10" frequency="3" timeframe="120">
    <if_matched_sid>5503</if_matched_sid>
    <description>Possible password guess on $(dstuser): 3 failed logins in a short period of time</description>
    <mitre>
      <id>T1110</id>
    </mitre>
  </rule>
</group>
```

ossec.conf

```
<ossec_config>
  <command>
    <name>disable-account</name>
    <executable>disable-account</executable>
    <timeout_allowed>yes</timeout_allowed>
  </command>

  <active-response>
    <disabled>no</disabled>
    <command>disable-account</command>
    <location>local</location>
    <rules_id>120100</rules_id>
    <timeout>300</timeout>
  </active-response>
</ossec_config>
```

Test:

Gib von ubuntu-mirror aus dreimal fuer block-me falsches Passwort ein. (Richtiges: block)

```bash
su block-me
su block-me
su block-me
sudo passwd --status block-me
```

Resultat in Wazuh: 
1. Possible password guess on block-me: 3 failed logins in a short period of time
2. Active response: active-response/bin/disable-account - add