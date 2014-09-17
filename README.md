# Docker development LAMP stack based on Ubuntu 12.04, using Apache, MySQL and PHP 5.3

## Overview

This is a Dockerfile and some configuration files to spin up a local development / runtime environment for Drupal development. It should be suitable for other PHP projects too, with minor adjustments.
Manage your project files using your favorite host based development tools (IDE, Sass, Compass, Bundler, ...). They are mounted inside the container's web root. MySQL data is kept persistent using another mounted folder.
The container shares ports 80, 3306 and 9000 with the host, for browsing, access to mysql data and debugging

## What's inside?

* Supervisor, to control multiple services running inside the container
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
* Several command line tools like mc, htop, curl, wget, patch

This is a localized german version, but it should be easy to adjust this

## Prerequisites

You should have installed the following tools:

* Your favorite development tools
* Docker: https://docs.docker.com/installation

## Usage

* Clone this repository: git clone https://github.com/drubb/phpdev-lamp53.git
* Make adjustments to Dockerfile and config files, if needed, e.g. for localization
* Optionally, create and populate a web root for your project files, e.g. 'www'
* Build your docker image, using a suitable tag: docker build -t myuser/myproject .
* Run your container

Running the container requires that you map some ports from container to host, and mount the folders for web root and mysql data. This is looking a little bit ugly, so maybe you should hide the command inside a shell script:

    docker run -ti -h docker \
               -v "$PWD/www":/var/www \
               -v "$PWD/database":/var/lib/mysql \
               -p 127.0.0.1:80:80 \
               -p 127.0.0.1:3306:3306 \
               -p 127.0.0.1:9000:9000 \
                myuser/myproject

## Passwords

If you don't adjust them, the container will use the following default users and passwords:

Docker user: docker, password docker  
MySQL root user: root, password root

The docker user can use sudo, without a password

## One more

DON'T USE THIS SETUP OR PARTS OF IT FOR PRODUCTION ENVIRONMENTS!!!
We don't care for security at all, this stuff is meant for developing environments solely.

## Have fun!
