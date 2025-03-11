**Physical work**

1. USB-Consolen Kabel Switch Console Port zu Linux Client anschliessen.
2. LAN Kabel Switch f0/1 zu Linux Client anschliessen.

**Linux Client**

1. Setze die IP-Adresse auf 10.0.0.10.
2. Greife über USB-Consolen Kabel auf die Switch zu:

```bash
sudo dmesg | grep tty
sudo screen /dev/ttyUSB0
```

**Cisco Switch**

```
interface Vlan1
ip address 10.0.0.10 255.255.255.0
no shutdown

hostname wosmOnpremSwitch
ip domain-name wosmOnprem.com
crypto key generate rsa modulus 2048
ip ssh version 2

username admin privilege 15 secret admin

line vty 0 4
transport input ssh
login local
```

**Mit SSH verbinden**

```bash
ssh -o KexAlgorithms=+diffie-hellman-group1-sha1 -o Ciphers=+aes128-cbc -o MACs=+hmac-sha1 -o HostKeyAlgorithms=+ssh-rsa admin@10.0.0.10
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