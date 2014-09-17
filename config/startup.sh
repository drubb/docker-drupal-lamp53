#!/bin/sh

# Forget about Debian frontend
unset DEBIAN_FRONTEND

# Restore initial MySQL configuration on first run
[ "$(sudo ls -A /var/lib/mysql)" ] || sudo tar xfzP /mysql.tar.gz

# Start needed services using supervisor
sudo service supervisor start

# Change owner of web root
sudo chown -R docker:docker /var/www/

# Run a new shell
/bin/zsh

# Stop all services
echo Shutting down all services...
sudo supervisorctl stop all
sudo supervisorctl shutdown

# Exit the container
exit
