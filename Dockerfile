FROM ubuntu:12.04
MAINTAINER Boris Böhne <info@drubb.de>

#
# Step 1: Installation
#

# Set frontend. We'll clean this later on!
ENV DEBIAN_FRONTEND noninteractive

# Expose web root as volume
VOLUME ["/var/www"]

# Update repositories cache
RUN apt-get -qq update

# Install some basic tools needed for deployment
RUN apt-get -yqq install sudo build-essential debconf-utils locales python-software-properties curl wget unzip patch dkms supervisor

# Add the docker user
ENV HOME /home/docker
RUN useradd docker && passwd -d docker && adduser docker sudo
RUN mkdir -p $HOME && chown -R docker:docker $HOME

# Install SSH client
RUN apt-get -yqq install openssh-client

# Install sendmail MTA @TODO: find a lightweight solution
RUN apt-get -yqq install sendmail

# Install Apache web server
RUN apt-get -yqq install apache2-mpm-prefork

# Install MySQL server
RUN echo "mysql-server mysql-server/root_password password root" | debconf-set-selections
RUN echo "mysql-server mysql-server/root_password_again password root" | debconf-set-selections
RUN apt-get -yqq install mysql-server

# Install PHP5 with Xdebug, APC and other modules
RUN apt-get -yqq install libapache2-mod-php5 php5-mcrypt php5-dev php5-mysql php5-curl php5-gd php5-intl php5-xdebug php-apc

# Install PEAR package manager
RUN apt-get -yqq install php-pear && pear channel-update pear.php.net && pear upgrade-all

# Install PECL package manager
RUN apt-get -yqq install libpcre3-dev

# Install PECL uploadprogress extension
RUN pecl install uploadprogress

# Install memcached service
RUN apt-get -yqq install memcached php5-memcached

# Install GIT (latest version)
RUN add-apt-repository ppa:git-core/ppa && apt-get -qq update && apt-get -yqq install git

# Install composer (latest version)
RUN curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer

# Install drush (latest stable)
USER docker
RUN composer global require drush/drush:6.*
USER root

# Install PhpMyAdmin (latest version)
RUN wget -q -O phpmyadmin.zip http://sourceforge.net/projects/phpmyadmin/files/latest/download && unzip -qq phpmyadmin.zip
RUN  rm phpmyadmin.zip && mv phpMyAdmin*.* /opt/phpmyadmin

# Install zsh / OH-MY-ZSH
RUN apt-get -yqq install zsh && git clone git://github.com/robbyrussell/oh-my-zsh.git $HOME/.oh-my-zsh

# Install some useful cli tools
RUN apt-get -yqq install mc htop

# Cleanup some things
RUN apt-get -yqq autoremove; apt-get -yqq autoclean; apt-get clean

# Expose some ports to the host system (web server, MySQL, Xdebug)
EXPOSE 80 3306 9000

# Run all services once for necessary initializations @TODO: Check if really necessary
RUN service apache2 start && service apache2 stop
RUN service memcached start && service memcached stop
RUN service mysql start && service mysql stop
RUN service sendmail start && service sendmail stop

#
# Step 2: Configuration
#

# Localization
RUN dpkg-reconfigure locales && locale-gen de_DE.UTF-8 && /usr/sbin/update-locale LANG=de_DE.UTF-8
ENV LC_ALL de_DE.UTF-8

# Set timezone
RUN echo "Europe/Berlin" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata

# Add apache web server configuration file
ADD config/httpd.conf /etc/apache2/httpd.conf

# Configure needed apache modules and disable default site
RUN a2enmod rewrite headers deflate expires && a2dismod cgi autoindex status && a2dissite default

# Add additional php configuration file
ADD config/php.ini /etc/php5/conf.d/php.ini

# Add additional mysql configuration file
ADD config/mysql.cnf /etc/mysql/conf.d/mysql.cnf

# Add phpmyadmin configuration file
ADD config/config.inc.php /opt/phpmyadmin/config.inc.php

# Add apc status script
RUN mkdir /opt/apc && gzip -c /usr/share/doc/php-apc/apc.php.gz > /opt/apc/apc.php

# Add zsh configuration
ADD config/.zshrc $HOME/.zshrc

# ADD ssh keys needed for connections to external servers
ADD .ssh $HOME/.ssh
RUN chmod 0700 $HOME/.ssh && chmod -f 0600 $HOME/.ssh/id_rsa || true && chmod -f 0644 $HOME/.ssh/id_rsa.pub || true
RUN  echo "    IdentityFile ~/.ssh/id_rsa" >> /etc/ssh/ssh_config

# Add startup script
ADD config/startup.sh $HOME/startup.sh

# Save MySQL initial configuration
RUN tar cpPzf /mysql.tar.gz /var/lib/mysql

# Supervisor configuration
ADD config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Entry point for the container
RUN chown -R docker:docker $HOME && chmod +x $HOME/startup.sh && chown -R docker:docker /var/www
USER docker
ENV SHELL /bin/zsh
WORKDIR /var/www
CMD ["/bin/bash", "-c", "$HOME/startup.sh"]
