#!/bin/bash
# Setup public - private key
mkdir -p /kaggle/working/.ssh
echo $1
FILE=/kaggle/working/.ssh/authorized_keys
if test -f "$FILE"; 
then
    wget $1 -O /kaggle/working/.ssh/temp
    cat /kaggle/working/.ssh/temp >> /kaggle/working/.ssh/authorized_keys
    rm /kaggle/working/.ssh/temp
else
    wget $1 -O /kaggle/working/.ssh/authorized_keys
fi

chmod 700 /kaggle/working/.ssh
chmod 600 /kaggle/working/.ssh/authorized_keys

# Install zrok
FILE=/kaggle/working/.zrok/zrok
if ! test -f "$FILE"; 
then
    wget https://github.com/openziti/zrok/releases/download/v0.0.1/zrok-linux-amd64 -O /kaggle/working/.zrok/zrok
    chmod +x /kaggle/working/.zrok/zrok
fi

# Install SSH-Server
sudo apt-get update
sudo apt-get install -y openssh-server

# SSH Config
sudo echo "PermitRootLogin no" >> /etc/ssh/sshd_config
sudo echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
sudo echo "AuthorizedKeysFile /kaggle/working/.ssh/authorized_keys" >> /etc/ssh/sshd_config
sudo echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config

sudo service ssh restart

# Start zrok tunnel
zrok tcp 22 --region ap
