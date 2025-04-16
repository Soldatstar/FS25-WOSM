# mirror with Virtualbox

**Installation**

1. Herunterladen des Ubunut image: https://ubuntu.com/download/server
2. Bridge Yellow im Lab
3. Neue VM: Base 4096, CPU 2, Disk 16GB
4. Starte. Network configuration: Edit enp0s3 ip4 manual: 172.16.0.0/24 172.16.0.7 172.16.0.1
5. Install OpenSSH server
6. user: ubuntu-mirror:wosm2025
7. reboot

**Enable ssh without ssh**

1. sudo nano /etc/ssh/sshd_config
2. add this on the bottom of the file: PasswordAuthentication yes
3. sudo service ssh restart
