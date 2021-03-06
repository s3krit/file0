![file0 logo](https://raw.githubusercontent.com/s3krit/file0/master/logo.png)

File0
=====

[![Build Status](https://travis-ci.org/s3krit/file0.svg?branch=master)](https://travis-ci.org/s3krit/file0)

File0 is a temporary file storage application, written in Sinatra for Ruby. It
stores files in Redis and sets a finite `EXPIRY` on them (default is 12 hours).
Depending on your configuration of Redis, this means it's possible for files to
have never touched the disk of the device.

Development
-----------

Clone this repository and run `bundle exec` in the directory (assuming
you have [Bundler](http://bundler.io/) installed). 

Install redis-server and make sure it's running.

```
# For debian/ubuntu
sudo apt-get install redis-server

# For Arch
pacman -Sy redis
sudo systemctl start redis-server

# For OS X
brew install redis

# For everything else
I don't know, please read your docs
```

In order to start the server, run the command `rackup`. This will start a
server on (by default) localhost:9292.

Deployment
----------

Haha, it's all manual! I've included a unicorn.rb file if you want to run it
that way. By default, it'll run it in a file socket that you can then point a
real webserver (like NGINX) at.

You've got a couple of options. Included is a basic unicorn.rb example
configuration file if you want to do things that way. Requires configuring your
webserver to point at the file socket, and everything should work.

However, because it's $CURRENT_YEAR, it also supports being deployed with
docker-compose. To run file0 with docker-compose, simply run the following
commands:

```
docker-compose build
docker-compose up
```

This will start the service in rackup on forwarded port 9292. To allow external
access, you will need to configure your webserver to proxy traffic to there.

Notes
-----

`TempFile` objects in Ruby get written to `/tmp`. In order to guarantee that
these files don't hit the disk, you'll need to make sure it's a proper `tmpfs`
(and probably disable swapping) or have it mounted as a RAM disk. As for Docker,
`docker-compose.yml` will make sure `/tmp` is a proper `tmpfs`. If you invoke
Docker on your own without `docker-compose`, you will have to add `--tmpfs /tmp`
to your Docker run command.
