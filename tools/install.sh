#!/bin/bash
set -e;

function set_config () {
  sed -i -e "/$1=/ s/=.*/=$2/" ~/.virtue_config
}

# Install Base Pacckages
if [ $6 == "precise" ]; then
  echo ">>> Installing Precise Base Packages"
  # Update
  sudo apt-get update
  # Install base packages
  sudo apt-get install -y unzip git-core ack-grep vim tmux curl wget build-essential python-software-properties

else
  echo ">>> Installing Trusty Base Packages"
  # Install base packages
bash << +END
sudo apt-get install -qq curl unzip git-core ack-grep
exit 0
+END

fi

echo ">>> Staring install"

# Install Virtue
VIRTUE=~/.virtue

if [ -d "$VIRTUE" ]; then
  echo "You already have Virtue installed. You'll need to remove $VIRTUE if you want to install"
  exit
fi

echo "Cloning Virtue..."
hash git >/dev/null 2>&1 && /usr/bin/env git clone https://github.com/jasonagnew/virtue.git $VIRTUE || {
  echo "git not installed"
  exit
}

echo "Looking for an existing Virtue config..."
if [ -f ~/.virtue_config ] || [ -h ~/.virtue_config ]; then
  echo "Found ~/.virtue_config. Backing up to ~/.virtue_config.pre-virtue";
  mv ~/.virtue_config ~/.virtue_config.pre-virtue;
fi

echo "Using the Virtue template file and adding it to ~/.virtue_config"
cp $VIRTUE/templates/virtue_config.template ~/.virtue_config
sed -i -e "/^VIRTUE=/ c\\
VIRTUE=$VIRTUE
" ~/.virtue_config

echo "Copying your current PATH and adding it to the end of ~/.virtue_config for you."
sed -i -e "/export PATH=/ c\\
export PATH=\"$PATH\"
" ~/.virtue_config

echo "Copying to bin directory"
sudo cp $VIRTUE/virtue.sh /usr/local/bin/virtue
sudo chmod a+x /usr/local/bin/virtue

# If domain set
if [[ -n "$1" ]]; then
    set_config "DOMAIN" $1
fi

if [[ -n "$2" ]]; then
    set_config "MYSQL_USER" $2
fi

if [[ -n "$3" ]]; then
    set_config "MYSQL_PASS" $3
fi

if [[ -n "$4" ]]; then
    set_config "MYSQL_REMOTE" $4
fi

if [[ -n "$5" ]]; then
    set_config "PHP_VERISON" $5
fi

if [[ -n "$6" ]]; then
    set_config "UBUNTU" $6
fi


# Load config file
source ~/.virtue_config

# Make git directory
sudo mkdir $GIT

if [ $UBUNTU == "precise" ]; then

  #PHP
  bash $VIRTUE/scripts/php.precise.sh

  #Apache
  bash $VIRTUE/scripts/apache.precise.sh

  #MySQL
  bash $VIRTUE/scripts/mysql.precise.sh

else

  #PHP
  bash $VIRTUE/scripts/php.trusty.sh

  #Apache
  bash $VIRTUE/scripts/apache.trusty.sh

  #MySQL
  bash $VIRTUE/scripts/mysql.trusty.sh

fi

echo "All finsihed"
