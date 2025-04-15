# gitea with Virtualbox

1. Youtube Tutorial: https://wiki.crowncloud.net/?How_to_Install_Gitea_on_Debian_12
2. Bridge Yellow im Lab

**Set DHCP**
sudo nano /etc/network/interfaces

```
auto enp0s3
iface eth0 inet static
address 172.16.0.6
netmask 255.255.255.0
gateway 172.16.0.1
```

**Login**

- debian debian-gitea:wosm2025
- web port 3000 soldatstar:wosm2025
 