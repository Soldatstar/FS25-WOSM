# gitea with Virtualbox

1. Youtube Tutorial: https://wiki.crowncloud.net/?How_to_Install_Gitea_on_Debian_12
2. Bridge Yellow im Lab
3. Pfsense DHCP MAC-IP: 08:00:27:56:bc:31-172.16.0.6

**Set DHCP**
sudo nano /etc/network/interfaces

```
auto enp0s3
iface enp0s3 inet dhcp
```

**Login**

- debian debian-gitea:wosm2025
- web port 3000 soldatstar:wosm2025
 