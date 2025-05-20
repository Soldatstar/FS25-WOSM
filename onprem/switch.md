**Physical work**

1. USB-Consolen Kabel Switch Console Port zu Linux Client anschliessen.
2. LAN Kabel Switch f0/1 zu Linux Client anschliessen.

**Linux Client**

Greife über USB-Consolen Kabel auf die Switch zu:

```bash
sudo dmesg | grep tty
sudo screen /dev/ttyUSB0
```

**Cisco Switch**

```
username wosm privilege 15 secret aW9pL3mS2tGb8Xz

vlan 99
name management
vlan 10
name internal
vlan 20
name dmz
vlan 30
name external

interface vlan 99
ip address 172.16.0.4 255.255.255.0
no shutdown

hostname wosmOnpremSwitch
ip domain-name wosmOnprem.com
crypto key generate rsa modulus 2048
ip ssh version 2

aaa new-model
aaa authentication login default local group radius
aaa authorization exec default local group radius
aaa accounting exec defaul start-stop group radius
aaa accounting network defaul start-stop group radius

aaa authentication dot1x default group radius
aaa authorization network default group radius
aaa accounting dot1x default start-stop group radius
dot1x system-auth-control

int g0/1
switchport mode trunk
int range f0/1-24
switchport mode access
int f0/1
switchport access vlan 99
int f0/2
switchport access vlan 10
int f0/3
switchport access vlan 20
int range f0/4-24
authentication port-control auto
dot1x pae authenticator

radius-server host 172.16.0.3 auth-port 1812 key Pasw0rd+

line vty 0 4
login authentication default
transport input ssh
```

Speichern: copy running-config startup-config
Löschen: delete vlan.dat, write erase, reload (System configuration has been modified. Save? [yes/no]: n)
Local Switch Fallback-Account: wosm:aW9pL3mS2tGb8Xz 

**Mit SSH verbinden**

```bash
ssh -o KexAlgorithms=+diffie-hellman-group1-sha1 -o Ciphers=+aes128-cbc -o MACs=+hmac-sha1 -o HostKeyAlgorithms=+ssh-rsa damjan@172.16.0.4
```

**Ansible Playbook ausführen**

1. Stelle sicher, dass die Ansible Cisco Modules installiert sind:

```bash
ansible-galaxy collection install cisco.ios
```

2. Playbooks werden dann wie folgt ausgeführt: 

```bash
ansible-playbook -i inventory.yml <playbook-name>.yml
```