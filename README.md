Docker running OTRS 3.2 ( with ITSM, FAQ, Support plugins) and MySQL
====================================================================

Here is simple Dockerfile to build OTRS 3.2 image to be run in Docker containers.

Note: it is not suitable for production (hardcoded passwords, single container, no special volume for database...). However it is well suited for development and installation testing (using docker commit etc).

Requirements
============

You need to have docker installed See https://docs.docker.com/installation/ubuntulinux/ for installation instructions. Note: It is recommended to run Docker on Ubuntu host. However the container itself is CentOS 6.4

Using and running latest image from automated build
---------------------------------------------------

Pull image
----------

	sudo docker pull hpaluch/docker-otrs

Run
---

Use this command to run OTRS in container named "MY_OTRS_INSTANCE":

	sudo docker run -P -d --name=MY_OTRS_INSTANCE hpaluch/docker-otrs

Use 

	sudo docker ps

to identify ports mapping (typicaly ports around 4915X)

* OTRS URL: http://YOUR_HOST:PORT/otrs/index.pl
* OTRS admin login/password: root@localhost/root
* SSH  login/password: root/changeme


Building and running from source
================================

Build
-----

	git clone https://github.com/hpaluch/docker-otrs.git
	cd docker-otrs
	sudo docker build -t MY_OTRS_IMAGE .

Run
---

Use this command to run image "MY_OTRS_IMAGE" on container named "MY_OTRS_INSTANCE":

	sudo docker run -P -d --name=MY_OTRS_INSTANCE MY_OTRS_IMAGE

Use 

	sudo docker ps

to identify ports mapping (typicaly ports around 4915X)

* OTRS URL: http://YOUR_HOST:PORT/otrs/index.pl
* OTRS admin login/password: root@localhost/root
* SSH  login/password: root/changeme


