# daloRADIUS with Virtualbox

**Installation**

1. Herunterladen des OVA: https://sourceforge.net/projects/daloradius/files/daloradius/daloRADIUS%20VM/
2. Bridge Yellow im Lab
3. Configure networking manually
4. 172.16.0.3 255.255.255.0 172.16.0.1
5. Reboot

6. First Web Login admin:admin
7. Second Web Login administrator:radius

**NAC for Switch**
1. Management>Nas>New Nas: IP 172.16.0.4, NAS Type cisco, NAS Secret Pasw0rd+ 
2. Management>User>Nwe User: damjan:damjan