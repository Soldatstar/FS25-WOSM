

| Net-Komponente | Zweck                          | Lab Interface    | VirtualBox                                |
| -------------- | ------------------------------ | ---------------- | ----------------------------------------- |
| opnsense       | VPN, Internet-Routing          | RED -> netlab    | WAN: Bridge, LAN: Inter Firewall          |
| pfsense        | Firewall, DPI, Zonen-Filterung | GREEN -> Switch  | WAN: Intern Firewall, LAN: Bridge         |
| vms            | Services                       | Switch -> YELLOW | VM Int.: Bridge (Each VM becomes its own) |



- 172.16.0.1: pfsense
- 172.16.0.3: radius
- 172.16.0.4: switch
- 172.16.0.5: wazuh
- 172.16.20.6: gitea
- 172.16.10.7: mirror

- 10.16.16.1: opnsense

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