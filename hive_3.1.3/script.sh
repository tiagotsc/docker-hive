#!/bin/bash

# Ajuste dos privilégios
sudo chown -R hduser:hadoop /home/hduser/jdk
sudo chown -R hduser:hadoop /home/hduser/hadoop
sudo chown -R hduser:hadoop /home/hduser/hive
sudo chown -R hduser:hadoop /home/hduser/tez

# Restart do serviço ssh
#sudo service ssh restart
#sudo systemctl restart sshd
