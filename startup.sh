#!/bin/sh

# Forget about Debian frontend
unset DEBIAN_FRONTEND

# Restore initial MySQL configuration on first run
[ "$(sudo ls -A /var/lib/mysql)" ] || sudo tar xfzP /mysql.tar.gz

# Start needed services using supervisor
sudo service supervisor start

# Set default ownership for home, ssh keys, web root and mysql (might have been modified from outside)
sudo chown -R docker:docker /home/docker
sudo chmod 0700 ~/.ssh && sudo chmod -f 0600 ~/.ssh/id_rsa || true && sudo chmod -f 0644 ~/.ssh/id_rsa.pub || true
sudo chown -R docker:docker /var/www/
sudo chown -R mysql:mysql /var/lib/mysql

# Run a new shell
/bin/zsh

# Stop all services
echo Shutting down all services...
sudo supervisorctl stop all
sudo supervisorctl shutdown

# Exit the container
exit
