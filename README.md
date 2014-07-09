Docker running OTRS 3.2 ( with ITSM FAQ Support) with MySQL
===========================================================

Here is simple Dockerfile to build OTRS 3.2 image to be run in Docker containers.

Build
-----
You need to have docker installed See https://docs.docker.com/installation/ubuntulinux/ for installation instructions. Note: It is recommended to run Docker on Ubuntu host. However the container itself is CentOS 6.4

Run this command to build image "MY_OTRS_IMAGE":

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


