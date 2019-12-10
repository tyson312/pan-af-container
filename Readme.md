# SE Training Dec 9, 2019

## Module 1: Docker

### Goal: 

* basic understanding of docker and how it works.

* build a containerized version of [p0lr's PAN-AF tool](https://github.com/p0lr/PAN-AF) for use at home.

### Background:

* Docker makes testing and/or deploying new software easy.

* PAN-AF is a tool for small static environments that maps MAC addresses to user-id's and then used the API of the firewall to transfer this information for use in security policy. It's lightweight and the perfect candidate for docker learning because it's not readily available as a container image yet.

### Docker basics

* a container is an instance of an image

* images are built from Dockerfiles, which is a script of { starting point + stuff to chagne/add + ports/storage to map }

* images can be grabbed from the docker hub website- which is quick and easy- but just like grabbing software off a torrent site- you don't know what you're actually running in your environment. Luckily, the hub shows the dockerfile and you can inspect and/or modify it as you see fit, then rebuild it yourself!

* _docker compose_ is a tool that can be used to run containers with a pre-build configuration without having to specify it on the command line at runtime. We'll look at this toward the end of the module.


**Prerequisites**

* Make sure you have docker installed on your oss-se-tools virtual machine. It should have been installed there by IT support but confirm it by running `docker ps -a`. [Here](https://docs.docker.com/v17.09/engine/installation/) are the installation instructions in case you need them. You will need to follow the appropriate operating system ones.


### Easy: DNS over TLS with stubby and Quad 9

1. `git clone https://github.com/oikuda/stubby-quad9.git`

2. change anything you want to

3. `build.sh` to compile it

4. `start.sh` to run it

5. `docker ps` to see that it's running

6. configure dns to use this machine 53/udp for resolution and then check the firewall traffic logs. Filter for port 853 or for dst eq 9.9.9.9


### Not as easy: Build PAN-AF from scratch then save it as your own image

1. Create a folder for this project and go there

2. `git clone https://github.com/tyson312/pan-af-container.git`

3. Go into the subfolder, look through the files, make edits as appropriate.

5. Build the image from the Dockerfile using `docker build -t panse/pan-af .`

6. When this completes, you will have an image that you can now deploy. The deployment can be done manually with a `docker run -it pan-af` command or with docker-compose which I think is more elegant.


### Docker compose

1. have a look at the docker-compose.yml file. [Documentation](https://docs.docker.com/compose/)

2. install docker compose: (note: it may be installed already.. check with docker-compose --version)
``` bash
sudo curl -L "https://github.com/docker/compose/releases/download/1.25.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose

docker-compose --version
```

3. In the docker-compose.yml file, confirm the image name, version, and other parameters match what you built.

4. Have a look at start-panaf.sh to see the syntax to bring up the image. Bring it up, either with the start.sh script or by hand.

*note*: When the container comes up, you'll see a lot of errors about apache etc. This is expected, because we have supervisor trying to launch software we haven't yet installed. 

5. The webgui isn't going to work yet. P0lr intended this install.sh script to be run on a raspberry pi to configure it as needed to run the tool. We have to do that now for the container. _Note: I modified the script to work on debian instead_

6. Open another terminal window. To get a bash prompt inside the running container, do `docker exec -it panaf /bin/bash` 

7. You're inside the container now. cd to /panaf and run `install.sh`

8. At this point the container should be prepped and the webgui for PAN-AF should be running.  Let's have a look at PAN-AF. Browse to [localhost on port 81](http://localhost:81)

9. You'll need to click on the logo to access the tool. Now it's time to configure the tool, starting with Manage Devices to generate an API key. [Here's](https://github.com/p0lr/PAN-AF) documentation on the PAN-AF tool in case you need help actually configuring/using it.

10. Now that it's running and configured, you likely want to save the container state to an image so you don't have to do steps 5-9 each time you stand up a new container instance. This is done with a _docker commit_ command and a new version number. Note the container name and the image name are identical in our example (thanks, docker-compose!) so this is easy. If you did it with docker exec, you would have some random string identifying the container such as "small_bassi" and would use that in place of *only* the first panaf in the command below. The second one is your image name.

_Be sure to exit out of the container before trying to commmit the container state! Press control-d or type exit._

``` bash
docker commit -m "comment here" -a "user or name here" panaf panse/panaf:v1
```

11. now you need to update the docker-compose.yml file to reflect the new version number you want to launch next time (the one you just saved, not the clean boot).

12. Try stopping the container with `docker stop panaf` or `docker-compose down`

13. Start it again with `docker-compose up -d`. It should come back to life in the state that you committed it.

### Extra Credit: Registries

You can check in your images to a registry like Docker Hub or your own. This is how you can publish them out to many hosts/users, or move them around.

Amazingly, you can run a docker registry as a docker container itself! [here](https://docs.docker.com/registry/deploying/) is the documentation on how to do this.


### Without a Registry

If you don't want to use a registry for your images, you can also move them around like this.

You will need to save the Docker image as a tar file:

`docker save -o <path for generated tar file> <image name>`
Then copy your image to a new system with regular file transfer tools such as cp, scp or rsync(preferred for big files). After that you will have to load the image into Docker:

`docker load -i <path to image tar file>`

Note: You should add filename (not just directory) with -o, for example:

`docker save -o c:/myfile.tar centos:16`

  [reference for this idea](https://stackoverflow.com/questions/23935141/how-to-copy-docker-images-from-one-host-to-another-without-using-a-repository)
