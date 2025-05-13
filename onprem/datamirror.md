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

**Enable Nginx DNS to access AWS**

AWS IAM Policies:

```
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "Statement1",
			"Effect": "Allow",
			"Action": [
				"route53:*"
			],
			"Resource": [
				"*"
			]
		}
	]
}
```

AWS IAM User (First create):

- Add FullRoute53Access Policy to created user 
- Go to Security Credentials>Access Keys
- Generate: Access key and Secret access key

**Backup using rsync**

ubuntu-mirror: 

```bash
echo ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCLmNQ8TchPdhqVA0h11f9fa0dAdssv7UaG4SoAz3Weq1l4ZDQf7lqHDrWCFxHoQE4G8Gk0+JRDMHdZCBUaw+eSez3OMommh6Du6Qt6qmrCCwmhFnDZJBGwXJJXQCC06I+0fKa0yeORNNh9lYcL0fURZSXV40Hw4GD8rdnjFoXLaQ2ZI8DuiaGx1gMv38RUQEVzEfUaTOfyC9Cahc3uQR1HOU8MXGIuxnjqxnWf7iLJDPRBhjzVnVnDnLxsy2C8wO7MXA6eXoeWWCVNrX1AQ8mbOut9FSLlAbEM8YZTLj8UXJiaXHFFUOBp8PeTkrRL7/mt1djsmC/qDy5y738IbS//09nQiXm5D6BunIajnUN7wIFe2hFkNjyfFixFumyfAXgL4FDRKJBysw/8ANJ2mh0AXi/YQ461stFcICmcDu6FLU29/H1ryu/Wi5sBOGEzCA58J8mk1mFTdmHhLmF8QU2M9snOxFPKB/GYZqJeLtK93tAaW9R3HcDew5xLp0q+Wtj8kvddIuJtuvP4RRgFABAENkqoPctcA6DgsRrgAqoq4/MPyRCvnwBcYA5dfMcM1ljs6ebnOhpjltTSu9sgGQMcgRkvNYAn5wrIyrDIaDSTX1SG8BfnYZk61dGAVQoqPFijiUcFhOKVLsy6Emy1Dc+FpXC0KYsy2f8JO8d/8j5UQQ== debian@ls-mediaserver > .ssh/authorized_keys
```

```bash
mkdir -p /home/ubuntu-mirror/backup/nextcloud_data
```

tempnote: 
-> 192.168.20.10:81
-> viktor.w50@gmail.com
-> wosm2025 