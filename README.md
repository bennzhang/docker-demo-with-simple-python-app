# python-app-docker-demo
This demo shows two steps:
+ Install `docker-ce` on Centos 7
+ Build and run a simple docker image with a python+flask+gunicorn web application.

## Install docker-ce on Centos 7
Refer to https://docs.docker.com/engine/installation/linux/docker-ce/centos/
You can also find [other OS installation docs from here](https://docs.docker.com/engine/installation).

#### Uninstall old versions
```
$ sudo yum remove docker \
                  docker-common \
                  docker-selinux \
                  docker-engine
```

#### Install using repository
```
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install docker-ce
sudo systemctl start docker
sudo docker run hello-world
```

Other commands: 
+ check docker status 
```
sudo systemctl status docker.service
```

+ stop docker 
```
sudo systemctl stop docker
```

+ uninstall docker-ce
```
sudo yum remove docker-ce
```

+ remove all images, container, volumes
```
sudo rm -rf /var/lib/docker
```

## Build/Run a simple python+flask docker web app 

#### Create the Dockerfile

```
FROM python:2.7

# Creating Application Source Code Directory
RUN mkdir -p /usr/src/app

# Setting Home Directory for containers
WORKDIR /usr/src/app

# Installing python dependencies
COPY requirements.txt /usr/src/app/
RUN pip install --no-cache-dir -r requirements.txt

# Copying src code to Container
COPY . /usr/src/app

# Application Environment variables
#ENV APP_ENV development
ENV PORT 8080

# Exposing Ports
EXPOSE $PORT

# Setting Persistent data
VOLUME ["/app-data"]

# Running Python Application
CMD gunicorn -b :$PORT -c gunicorn.conf.py main:app
```

#### Build your image
Normally, image name convention is something like: `
{company/application-name}:{version-number}`. In the demo, I just use `{application-name}:{version-number}`

```
sudo docker build -t my-python-app:1.0.1 .
```

#### check all docker images
```
$ sudo docker images
REPOSITORY              TAG                 IMAGE ID            CREATED             SIZE
my-python-app           1.0.1               2b628d11ba3a        22 minutes ago      701.6 MB
docker.io/python        2.7                 b1d5c2d7dda8        13 days ago         679.3 MB
docker.io/hello-world   latest              05a3bd381fc2        5 weeks ago         1.84 kB
```

`2b628d11ba3a` is the image ID, some commands based on the ID.

+ tag 
```
sudo docker tag 2b628d11ba3a my-python-app:1.0.1
sudo docker tag 2b628d11ba3a my-python-app:latest
```

+ remove image
```
$ sudo docker rmi --force 2b628d11ba3a
```

#### Run your image
```
$ sudo docker run -d -p 8080:8080 my-python-app:1.0.1
```


You can use `sudo docker ps` to list all running containers. 
```
$ sudo docker ps
CONTAINER ID        IMAGE                 COMMAND                  CREATED             STATUS              PORTS                    NAMES
4de6041072b7        my-python-app:1.0.1   "/bin/sh -c 'gunicorn"   20 minutes ago      Up 20 minutes       0.0.0.0:8080->8080/tcp   elegant_kowalevski
```

`4de6041072b7` is the running container id. Some commands below are what you might need.

+ display logs in running container
```
$ sudo docker logs 4de6041072b7
[2017-10-23 20:29:49 +0000] [7] [INFO] Starting gunicorn 19.6.0
[2017-10-23 20:29:49 +0000] [7] [INFO] Listening at: http://0.0.0.0:8080 (7)
[2017-10-23 20:29:49 +0000] [7] [INFO] Using worker: gthread
[2017-10-23 20:29:49 +0000] [11] [INFO] Booting worker with pid: 11
[2017-10-23 20:29:49 +0000] [12] [INFO] Booting worker with pid: 12

```

+ stop your container
```
$ sudo docker stop 4de6041072b7
```

+ login inside the container
```
$ sudo docker exec -it 4de6041072b7 /bin/sh
# ls /usr/src/app
Dockerfile  README.md  gunicorn.conf.py  gunicorn_pid.txt  main.py  main.pyc  requirements.txt
# exit
```

#### Test your application
```
$ curl http://localhost:8080
Hello World
```
