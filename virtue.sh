#!/bin/bash
set -e;

# Check if name is specified
if [[ $1 == *:* ]]; then
    if [[ -z $2 ]]; then
        echo "You must specify an app name"
        exit 1
    else
      APP="$2"
    fi
fi

# Check for config file
if [ ! -f ~/.virtue_config ]; then
    echo "Sorry your config file is missing: ~/.virtue_config"
    exit 1;
fi

# Load config file
source ~/.virtue_config

case "$1" in

  add:sendmail)

    sudo apt-get install -y sendmail && echo "Sendmail installed"

  ;;

  site:create)

    # Setup Git Remote & Deployment
    sudo mkdir $PUBLIC/$APP
    sudo mkdir $GIT/$APP.git
    cd $GIT/$APP.git
    git init --bare
    cat > hooks/post-receive <<-EOF
      #!/bin/sh
      git --work-tree=$PUBLIC/$APP --git-dir=/$GIT/$APP.git checkout -f
EOF
    chmod +x hooks/post-receive

    # Setup Subdomain
    sudo vhost -s $DOMAIN -d $PUBLIC/$APP/public
    sudo vhost -s www.$DOMAIN -d $PUBLIC/$APP/public


    sudo mkdir /etc/apache2/ssl

    openssl genrsa -out /etc/apache2/ssl/server.key 1024
    touch /etc/apache2/ssl/openssl.cnf
    cat >> /etc/apache2/ssl/openssl.cnf <<EOF
[ req ]
prompt = no
distinguished_name = req_distinguished_name

[ req_distinguished_name ]
C = GB
ST = Test State
L = Test Locality
O = Org Name
OU = Org Unit Name
CN = Common Name
emailAddress = test@email.com
EOF

    openssl req -config /etc/apache2/ssl/openssl.cnf -new -key /etc/apache2/ssl/server.key -out /etc/apache2/ssl/server.csr
    openssl x509 -req -days 1024 -in /etc/apache2/ssl/server.csr -signkey /etc/apache2/ssl/server.key -out /etc/apache2/ssl/server.crt

    sudo vhost -s $DOMAIN -d $PUBLIC/$APP/public -p /etc/apache2/ssl -c server
    sudo vhost -s www.$DOMAIN -d $PUBLIC/$APP/public -p /etc/apache2/ssl -c server

    # Setup MySQL Database
    mysql -u $MYSQL_USER -p$MYSQL_PASS -e "CREATE DATABASE ${APP//-/_}"
    echo "Site created"
  ;;

  app:create)

    # Setup Git Remote & Deployment
    sudo mkdir $PUBLIC/$APP
    sudo mkdir $GIT/$APP.git
    cd $GIT/$APP.git
    git init --bare
    cat > hooks/post-receive <<-EOF
      #!/bin/sh
      git --work-tree=$PUBLIC/$APP --git-dir=/$GIT/$APP.git checkout -f
EOF
    chmod +x hooks/post-receive


    # Setup Subdomain
    sudo vhost -s $APP.$DOMAIN -d $PUBLIC/$APP/public

    # Setup MySQL Database
    mysql -u $MYSQL_USER -p$MYSQL_PASS -e "CREATE DATABASE ${APP//-/_}"
    echo "App created"
  ;;

  app:delete)

    # Remove Git Remote & Deployment
    sudo rm -rf $PUBLIC/$APP
    sudo rm -rf $GIT/$APP.git

    # Diable & Remove Subdomain
    sudo a2dissite $APP.$DOMAIN
    service apache2 reload
    sudo rm -rf /etc/apache2/sites-available/$APP.$DOMAIN.conf

    # Drop MySQL Database
    mysql -u $MYSQL_USER -p$MYSQL_PASS -e "DROP DATABASE ${APP//-/_}"
    echo "App deleted"
  ;;

  -v)
    echo "Verison 0.2"
  ;;

  update)
    echo "Updating..."
    curl -L -H 'Cache-Control: no-cache' https://raw.githubusercontent.com/jasonagnew/virtue/master/virtue.sh > /usr/local/bin/virtue
    sudo chmod a+x /usr/local/bin/virtue
    echo "Update complete"
    exit 1
  ;;

  *)
    echo "Virtue"
    echo "site:create <site-name> Create site, naked domain plus www with self-signed ssl"
    echo "app:create <app-name>   Create app"
    echo "app:delete <app-name>   Delete app"
    echo "-v                      Check verison"
    echo "update                  Update Virtue"
  ;;

esac
