

| Net-Komponente | Zweck                          | Lab Interface               | VirtualBox                                |
| -------------- | ------------------------------ | --------------------------- | ----------------------------------------- |
| opnsense       | VPN, Internet-Routing          | USB -> netlab               | WAN: Bridge, LAN: Intern Firewall         |
| pfsense        | Firewall, Zonen-Filterung      | GREEN -> Switch             | WAN: Intern Firewall, LAN: Bridge         |
| vms            | Services                       | Switch -> YELLOW, BLUE, RED | VM Int.: Bridge (Each VM becomes its own) |



- 172.16.0.1: pfsense | ssh admin@172.16.0.1 passwd: pfsense
- 172.16.0.3: radius | ssh -oHostKeyAlgorithms=+ssh-rsa -oPubkeyAcceptedAlgorithms=+ssh-rsa root@172.16.0.3 passwd: daloradius
- 172.16.0.4: switch | ssh -o KexAlgorithms=+diffie-hellman-group1-sha1 -o Ciphers=+aes128-cbc -o MACs=+hmac-sha1 -o HostKeyAlgorithms=+ssh-rsa wosm@172.16.0.4 passwd: aW9pL3mS2tGb8Xz
- 172.16.0.5: wazuh | ssh wazuh-user@172.16.0.5 passwd: wazuh
- 172.16.20.6: gitea | ssh debian-gitea@172.16.20.6 passwd: wosm2025
- 172.16.10.7: mirror | ssh ubuntu-mirror@172.16.10.7 passwd: wosm2025

- 10.16.16.1: opnsense | ssh root@10.16.16.1 passwd: opnsense

# pfSense with Virtualbox

**CLI**

1. Herunterladen des Images: https://atxfiles.netgate.com/mirror/downloads/ 
2. Neue VM: Type BSD, Version FreeBSD (64-bit), Base 4096, CPU 2, Disk 16GB

**Installer**

1. Auto ZFS
2. Pool Type stripe
3. Select VBOX_HARDDISK (By clicking SPACE)
4. Confirm, Reboot, bei Virtualbox Disk aus dem Storage rausnehmen.

**Interface VLANs**

1. Assign Interaface
2. Vlans -> parent LAN, 99, 10, 20, 30
3. WAN -> internal firewall, LAN -> bridge green
4. Set interface IP address
5. WAN: 10.16.16.1/30, LAN: 192.168.1.1/24
6. 99: 172.16.0.1, 10:172.16.10.1 20:172.16.20.1 30:172.16.30.1
7. DHCP 99:172.16.0.10-172.16.0.254, 10:172.16.10.10-172.16.10.254 20:172.16.20.10-172.16.20.254 30:172.16.30.10-172.16.30.254
8. 192.168.1.1 WEB GUI admin:pfsense -> any rule on any vlan (for now)
9. Services>DHCP Server: DNS 10.51.2.232 for each vlan (for now)

**Wazuh-Agent**

```bash
pkg update
pkg install nano
nano /usr/local/etc/pkg/repos/pfSense.conf
nano /usr/local/etc/pkg/repos/FreeBSD.conf
```

Change: 

```
FreeBSD: { enabled: yes }
```

```bash
pkg update
pkg search wazuh-agent
pkg install wazuh-agent-x.xx.x
cp /etc/localtime /var/ossec/etc
cp /var/ossec/etc/ossec.conf{.sample,}
nano /var/ossec/etc/ossec.conf
```

Change: 

```
<server>
    <address>172.16.0.5</address>
    <port>1514</port>
    <protocol>tcp</protocol>
</server>
```

```bash
sysrc wazuh_agent_enable="YES"
ln -s /usr/local/etc/rc.d/wazuh-agent /usr/local/etc/rc.d/wazuh-agent.sh
service wazuh-agent start
```