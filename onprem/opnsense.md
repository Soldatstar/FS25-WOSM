# OPNsense with Virtualbox

**CLI**

1. Herunterladen des Images: amd64, dvd, LeaseWeb
2. Neue VM: Type BSD, Version FreeBSD (64-bit), Base 4096, CPU 2, Disk 16GB
3. User: installer, Password: opnsense

**Installer**

1. Keymap selection, Testen, dann erster Eintrag fuer weiter
2. Install by ZFS filesystem.
3. Choose stripe device type.
4. Select VBOX_HARDDISK (By clicking SPACE)
5. Confirm, Reboot, bei Virtualbox Disk aus dem Storage rausnehmen.

**Interfaces**

1. User: root Password: opnsense
1. Assign Interaface
2. WAN -> bridge red, LAN -> internal firewall
3. Set interface IP address
4. Choose LAN and for ipv4: 172.16.0.1
5. Choose WAN and DHCP

