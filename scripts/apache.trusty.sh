#!/bin/bash

# Load config file
source ~/.virtue_config

# Test if PHP is installed
php -v > /dev/null 2>&1
PHP_IS_INSTALLED=true


echo ">>> Installing Apache Server"

public_folder="$PUBLIC"

github_url="https://raw.githubusercontent.com/fideloper/Vaprobash/master"


# Add repo for latest FULL stable Apache
# (Required to remove conflicts with PHP PPA due to partial Apache upgrade within it)
sudo add-apt-repository -y ppa:ondrej/apache2


# Update Again
sudo apt-key update
sudo apt-get update

# Install Apache
# -qq implies -y --force-yes
sudo apt-get install -qq apache2 apache2-mpm-event

echo ">>> Configuring Apache"


# Apache Config
sudo a2dismod php5 mpm_prefork
sudo a2enmod mpm_worker rewrite actions ssl
curl --silent -L $github_url/helpers/vhost.sh > vhost
sudo chmod guo+x vhost
sudo mv vhost /usr/local/bin

# If PHP is installed or HHVM is installed, proxy PHP requests to it
if [[ $PHP_IS_INSTALLED -eq 0 ]]; then

    # PHP Config for Apache
    sudo a2enmod proxy_fcgi
else
    # vHost script assumes ProxyPassMatch to PHP
    # If PHP is not installed, we'll comment it out
    sudo sed -i "s@ProxyPassMatch@#ProxyPassMatch@" /etc/apache2/sites-available/$1.xip.io.conf
fi

sudo service apache2 restart
