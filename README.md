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
I don't know, read your goddamn docs
```

In order to start the server, run the command `rackup`. This will start a
server on (by default) localhost:9292.

Deployment
----------

Haha, it's all manual! I've included a unicorn.rb file if you want to run it
that way. By default, it'll run it in a file socket that you can then point a
real webserver (like NGINX) at.

Don't worry, one day this will all be dockerized and docker composed. I
promise. I wouldn't lie to you.

Notes
-----

I don't know for a fact that the `TempFile` objects provided by Sinatra don't
hit the disk. It's pretty important I find this out cause otherwise, one of the
main draws of it is moot.

It also needs to self-host bootstrap, jquery, etc.
