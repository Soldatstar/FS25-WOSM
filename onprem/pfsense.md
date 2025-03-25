

| Net-Komponente | Zweck                          | Lab Interface    | VirtualBox                                |
| -------------- | ------------------------------ | ---------------- | ----------------------------------------- |
| opnsense       | VPN, Internet-Routing          | RED -> netlab    | WAN: Bridge, LAN: Inter Firewall          |
| pfsense        | Firewall, DPI, Zonen-Filterung | GREEN -> Switch  | WAN: Intern Firewall, LAN: Bridge         |
| vms            | Services                       | Switch -> YELLOW | VM Int.: Bridge (Each VM becomes its own) |

- 172.16.0.1: opnsense
- 172.16.0.2: pfsense
- 172.16.0.3: radius
- 172.16.0.4: switch

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
4. Choose LAN ipv4 172.16.0.2

**Transparent Filtering Bridge**
- With client assign ip4 adress in 172.16.0.0/24 then go in browser to 172.16.0.2
- Browser -> 172.16.0.2 admin:pfsense
- Firewall>NAT>Outbound: select “Disable Outbound NAT rule generation”.
- System>Advanced>System-Tunables: net.link.bridge.pfil_bridge from default to 1.
- System>Advanced>System-Tunables: net.link.bridge.pfil_member from default to 0.
- Interfaces>Assignments>Bridges: Choose LAN and WAN (by holding shift).
- Interfaces>Assignments: select the bridge from the list and hit + then select enable interface. (Add ip4 skipped for now)
- Interfaces>Assignments>WAN: unselect Block private networks and Block bogon networks.
- Firewall>Rules: WAN, LAN, OPT1 Allow all rules and delete all other rules. (Anti-Lockout-Rule later)
- Interfaces>LAN, Interfaces>WAN: ip4 config type to none.
- Virtualbox: opnsense and pfsense LAN, WAN Promiscuous Mode: Allow All
- Give OPT the ip4 172.16.0.2
 