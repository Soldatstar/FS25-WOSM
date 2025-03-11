

| Net-Komponente | Zweck                          | Lab Interface    | VirtualBox                                |
| -------------- | ------------------------------ | ---------------- | ----------------------------------------- |
| opnsense       | VPN, Internet-Routing          | RED -> netlab    | WAN: Bridge, LAN: Inter Firewall          |
| pfsense        | Firewall, DPI, Zonen-Filterung | GREEN -> Switch  | WAN: Intern Firewall, LAN: Bridge         |
| vms            | Services                       | Switch -> YELLOW | VM Int.: Bridge (Each VM becomes its own) |

# pfSense with Virtualbox

**CLI**

1. Herunterladen des Images: https://atxfiles.netgate.com/mirror/downloads/ 
2. Neue VM: Type BSD, Version FreeBSD (64-bit), Base 4096, CPU 2, Disk 16GB

**Installer**

1. Auto ZFS
2. Pool Type stripe
3. Select VBOX_HARDDISK (By clicking SPACE)
4. Confirm, Reboot, bei Virtualbox Disk aus dem Storage rausnehmen.

**Interface**

1. Assign Interaface
2. WAN -> internal firewall, LAN -> bridge green
3. Set interface IP address
4. Choose WAN and for ipv4: 172.16.0.2
5. Choose WAN upstream ipv4: 172.16.0.1
5. Choose LAN ipv4 10.0.0.1

**Test**

Ubuntu 10.0.0.15, Default 10.0.0.1, DNS  10.51.2.232
Browser -> 172.16.0.1 root:opnsense
Browser -> 10.0.0.1 admin:pfsense
 