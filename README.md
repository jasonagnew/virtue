# Virtue

Virute is super simple server setup. With one command you can create an app with git remote deployment, subdomain & MySQL database

**Note**: Some of the LAMP set up is based the awesome [Vaprobash](https://github.com/fideloper/Vaprobash)  

## Requirements

Ubuntu Trusty or Precise. Ideally have a domain ready to point to your host. It's designed for and is probably best to use a fresh VM. The installer will install everything it needs.

Please ensure you have set up your ssh keys, like so:

    $ cat ~/.ssh/id_rsa.pub | ssh [user]@[ip-address] "cat >> ~/.ssh/authorized_keys"

If you plan to use the server ssh on non-standard port (not 22) then on your local machine set this port for git:

    $ nano ~/.ssh/config

Add:

    Host [ip-address]
      Port [port]


## Installing

    $ curl -L https://raw.githubusercontent.com/jasonagnew/virtue/master/tools/install.sh | bash -s [domain] [mysql-user] [mysql-password] [mysql-remote] [php-verson] [ubuntu-verison]

Please complete the variables in the brackets, examples below. The install may take around 5 minutes.

### Options

    [mysql-remote]     true|false
    [php-verson]       latest|previous|distributed  (5.5|5.4|5.3) *Note: Trusty doesn't support 5.3
    [ubuntu-verison]   trusty|precise

### Example - Trusty with PHP 5.5

    $ curl -L https://raw.githubusercontent.com/jasonagnew/virtue/master/tools/install.sh | bash -s bigbitecreative.com root pass1234 true latest trusty

### Example - Precise with PHP 5.3

    $ curl -L https://raw.githubusercontent.com/jasonagnew/virtue/master/tools/install.sh | bash -s bigbitecreative.com root pass1234 true distributed precise

## Deploy a Site

A site in Virtue is the main app used on the server, it will set up the naked domain plus the `www` subdomain. It will also set up self-signed SSL certs (which can be replaced afterwards). To create a site, SSH onto the server and execute:

    $ virtue site:create my-site

## Deploy an App

Now you can deploy apps on Virtue. Let's start by creating your app. SSH onto the server, then execute:

    $ virtue app:create my-app


Then on your local machine. Go into project folder and your git remote.

**Note**: Remember to complete the brackets with your own details

    $ cd my-app
    $ git remote add dev-server [user]@[ip-address]:/var/repo/my-app.git
    $ git push dev-server [local-branch]:master

You're done! Your app will be viewable from `my-app.domain.com`. Your database will be accessible through `localhost` with the app name using underscores not dashes `my_app`


## Removing a deployed app

SSH onto the server, then execute:

    $ virtue app:delete my-app

## License

MIT
