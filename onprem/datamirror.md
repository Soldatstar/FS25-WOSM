# mirror with Virtualbox

**Installation**

1. Herunterladen des Ubunut image: https://ubuntu.com/download/server
2. Bridge Yellow im Lab
3. Neue VM: Base 4096, CPU 2, Disk 16GB
4. Starte. Network configuration: Edit enp0s3 ip4 manual: 172.16.0.0/24 172.16.0.7 172.16.0.1
5. Install OpenSSH server
6. user: ubuntu-mirror:wosm2025
7. reboot

**Enable ssh without key validation**

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

```bash
echo <pub-key from media server> > .ssh/authorized_keys
```

```bash
mkdir -p /home/ubuntu-mirror/backup/nextcloud_data
```

**HTTP File Server**

```bash
sudo nano /etc/systemd/resolved.conf
```

```
DNS=10.51.2.232
```

```bash
sudo systemctl restart systemd-resolved
sudo apt update
sudo apt install build-essential
curl https://sh.rustup.rs -sSf | sh (need to tipe enter)
source $HOME/.cargo/env
cargo install miniserve
sudo nano /etc/systemd/system/miniserve.service
```

```
[Unit]
Description=Miniserve file server
After=network.target

[Service]
Type=simple
ExecStart=/home/ubuntu-mirror/.cargo/bin/miniserve /home/ubuntu-mirror/backup/nextcloud_data --interfaces 0.0.0.0 --port 8080
Restart=on-failure
User=ubuntu-mirror
WorkingDirectory=/home/ubuntu-mirror

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable miniserve
sudo systemctl start miniserve
```