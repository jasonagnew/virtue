# Virtue

Virute is super simple server setup. With one command you can create an app with git remote deployment, subdomain & MySQL database

**Note**: Some of the LAMP set up is based the awesome https://github.com/fideloper/Vaprobash

## Requirements

Ubuntu 13.10. Ideally have a domain ready to point to your host. It's designed for and is probably best to use a fresh VM. The installer will install everything it needs.

Please ensure you have set up your ssh keys, like so:

    $ cat ~/.ssh/id_rsa.pub | ssh [user]@[ip-address] "cat >> ~/.ssh/authorized_keys"

If you plan to use the server ssh on non-standard port (not 22) then on your local machine set this port for git:

    $ nano ~/.ssh/config

Add:

    Host [ip-address]
      Port [port]


## Installing

### Development

    $ curl -L https://raw.githubusercontent.com/jasonagnew/virtue/master/tools/install.sh | bash -s [domain] [mysql-user] [mysql-password] [mysql-remote]

Please complete the variables in the brackets, example below. This install may take around 5 minutes.

### Example

    $ curl -L https://raw.githubusercontent.com/jasonagnew/virtue/master/tools/install.sh | bash -s bigbitecreative.com root pass1234 true


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
