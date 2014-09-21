# Docker development LAMP stack based on Ubuntu 12.04, using Apache, MySQL and PHP 5.3

## Overview

This is a Dockerfile and some configuration files to spin up a local development / runtime environment for Drupal development. It should be suitable for other PHP projects too, with minor adjustments.
Manage your project files using your favorite host based development tools (IDE, Sass, Compass, Bundler, ...). They are mounted inside the container's web root. MySQL data is kept persistent using another mounted folder.
The container shares ports 80, 3306 and 9000 with the host, for browsing, access to mysql data and debugging

## What's inside?

* Supervisor, to control multiple services running inside the container
* OpenSSH client
* SSMTP, a lightweight smtp MTA
* Apache 2.2, MySQL 5.5 & PHP 5.3
* APC opcode cache
* MemCached service and php extension
* Xdebug php extension
* PhpMyAdmin (latest version)
* PEAR and PECL package managers
* Composer (latest version)
* Git (latest version)
* Drush (stable)
* ZSH / Oh-My-ZSH
* PROST drupal deployment scripts, see https://www.drupal.org/sandbox/axroth/1668300
* Several command line tools like mc, htop, curl, wget, patch

This is a localized german version, but it should be easy to adjust this

## Prerequisites

You should have installed the following tools:

* Your favorite development tools
* Docker: https://docs.docker.com/installation

## Usage

* Clone this repository: git clone https://github.com/drubb/phpdev-lamp53.git
* Make adjustments to Dockerfile and config files, if needed, e.g. for localization, git user, mail server, ...
* Add your ssh keys to .ssh folder, if needed for connections to external servers, e.g. repos
* Optionally, create and populate a web root for your project files, e.g. 'www'
* Build your docker image, using a suitable tag: docker build -t myuser/myproject .
* Run your container

Running the container requires that you map some ports from container to host, and mount the folders for web root and mysql data. This is looking a little bit ugly, so maybe you should hide the command inside a shell script:

    docker run -ti -h myhostname \
               -v "$PWD/www":/var/www \
               -v "$PWD/database":/var/lib/mysql \
               -p 127.0.0.1:80:80 \
               -p 127.0.0.1:3306:3306 \
               -p 127.0.0.1:9000:9000 \
                myproject

If one or more ports are already in use on your host system, just assign other port numbers. Here's an example:

    docker run -ti -h myhostname \
               -v "$PWD/www":/var/www \
               -v "$PWD/database":/var/lib/mysql \
               -p 127.0.0.1:8080:80 \
               -p 127.0.0.1:3307:3306 \
               -p 127.0.0.1:9001:9000 \
                myproject

In this case, you would be browsing using localhost:8080, and your external connections to database and debugger
would use the ports 3307 and 9001. You might also assign different IPs, consult the docker documentation for details.

Want some shellscript magic? Replace `myhostname` and `myproject` by `${PWD##*/}`
to use the last part of your project's folder path instead.

## Working with the container

When you run the container, you're presented a shell and located inside your web root. You can use the tools provided by
the container, like linux command line tools, mc, git or drush. Keep in mind however, that only your web root (and the
mysql database) is kept persistent, other things you modify will be gone when you stop the container. So it's almost
useless to install or update packages, modify config files or storing things in your home directory - except of making
temporary changes for testing purposes at runtime.

There's another caveat, regarding services running inside the container:
Services like Apache or MySQL are controlled by Supervisor. You shouldn't stop or restart them using the usual
linux service commands, because Supervisor would loose control and your services wouldn't be shut down smoothely
when the container stops. There's however an equivalent Supervisor tool for this purpose, **supervisorctl**.

So don't do this:

    sudo service apache2 restart

Use instead:

    sudo supervisorctl restart apache2

Besides your web root, there are two special paths you can lookup in your browser:

You can use **PhpMyAdmin** under /phpmyadmin, and view the status of **APC** opcode cache under /apc.

Want to stop the container? Just type **exit**!

## Passwords

If you don't adjust them, the container will use the following default users and passwords:

Docker user: docker, no password
MySQL root user: root, password root

The docker user can use sudo, without a password

## One more

DON'T USE THIS SETUP OR PARTS OF IT FOR PRODUCTION ENVIRONMENTS!!!

We don't care for security at all, this stuff is meant for development environments solely.

## Have fun!
