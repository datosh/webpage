---
title: Docker Image with CMake 3.9.4
description: Setting up a Docker Image with CMake 3.9.4
date: 2017-10-03 17:00:00
categories:
 - tutorial
tags:
 - Continuous Integration
 - Docker
 - CMake
---

## Docker + CMake

In this article we will learn how to extend a Docker Base Image, by adding our
own tools to it. As stated in the introduction post to this series, we will use
Ubuntu 16.04 LTS (Xenial) as our main operating system, and therefore will also
choose the same Base Image. Although, it is possible to
[mix host and container OSs](https://stackoverflow.com/a/18859958/2306355)
to some degree.

All files used for this article can be found on my
[github](https://github.com/datosh/CppDev/tree/master/Container/10_CMake).

If you just want to use the created Docker Image feel free to pull it from my
[Docker Hub](https://hub.docker.com/r/datosh/xenial_cmake/)

### Dockerfile

The `Dockerfile` defines how a new Docker Image is created. In the following
I will explain each part of the Dockerfile.

First, we state the image we want to use as our starting point. Since we
have nothing to start from, we need a Base Image. These are provided by all
OS suppliers, and can be found via the [Docker Hub](https://hub.docker.com/).
Creating our own Base Image is also possible, but not trivial. Therefore
we use an official one for now. I might go over how to create a Base Image
in a future article.

For now, simply search for `Ubuntu`, and the official ubuntu
repository should show up. Since we want to use Ubuntu 16.04 LTS, we use the
tag `xenial`.
```sh
FROM ubuntu:xenial
```

Next on, it is common to state the maintainer of the image, so bugs can be
reported to this person.
```sh
LABEL maintainer="datosh@gmx.de"
```

Now we need some files to actually work with when creating our new Docker Image.
Therefore we set our work directory to `/workdir` and copy the contents of our
current folder into this directory. For this image we are interested in copying
the `build_cmake.sh` file, which resides next to the `Dockerfile`, cf.
[github](https://github.com/datosh/CppDev/tree/master/Container/10_CMake).
We will go over the contents of this script in the next section.
```sh
WORKDIR /workdir
ADD . /workdir
```

The actual work when creating a new Docker Image is done in one (or multiple) 
`RUN` command(s).
First, we update our package manager, and install the packages required to
build CMake 3.9.4. To keep our footprint low we use the
`--no-install-recommends` flag to only install what we ask for. Afterwards we
execute the script that will actually install CMake, and remove all temporary
files downloaded by `apt-get`.
```sh
RUN apt-get update && \
	apt-get -y --no-install-recommends install cmake make gcc g++ wget ca-certificates && \
	./build_cmake.sh && \
	rm -rf /var/lib/apt/lists/*;
```
**NOTE**: That we do all of this in a single command. It is possible to split
this into multiple `RUN` commands and make the `Dockerfile` more readable. The
advantage of stating everything on a single line, is that Docker will create a
snapshot of each stage, where each stage is a single command. Since we want to
keep our footprint small we need to delete the files we are not interested in
the same step we are creating them, or else they will be stored by a snapshot.
So running `apt-get update` and removing
it's downloaded files via `rm -rf /var/lib/apt/lists/*` need to happen in the
same step!

### Building CMake

Please refer to the `build_cmake.sh` script for all necessary steps.

This script contains all commands needed to download the CMake source files, and
compile, and install them to our system. We also remove all temporary files
(the source files we've downloaded, and our build folder), as well as the 
outdated CMake package we've installed earlier via `apt-get` to make the 
CMake compilation easier.

I will not go over each command in this file, since it is fairly straight
forward, and the actual focus of this article is Docker. The CMake build system
will be covered in the future. If you still have problems or questions,
leave a comment or send me a tweet. :)

More information regarding the installation of CMake can be found on
[Kitware's Github](https://github.com/Kitware/CMake).

### Running It

Now that everything is in place we need to actually trigger the creation of the
new Docker Image. All necessary steps can be found in the `run.sh` file, but I
will go over each command here as well:

First we need to build the new image using the `docker build` command. Via the
`-t` flag we specify a tag name for the new image. In this case we call the new
image `xenial_cmake`. We also need to specify the location of the `Dockerfile`
we want to use. In our case it is the current directory `.`. Keep in mind that
our `Dockerfile` expects the `build_cmake.sh` script to be in the same
directory. So make sure you `cd` to the correct directory before you enter
the command. 

Since a `docker build` might run for a long time, and produces a lot of output
I like to safe the log using `tee`. This especially helps with debugging if the
creation of the new image fails.

```sh
docker build -t xenial_cmake . | tee build.log
```

Finally we tag our image using the name from the last step to identify it.
Our new tag consists of three parts:

* `datosh` is the repository owner
* `xenial_cmake` is the repository name
* `v3.9.4` is the version, or again tag

```sh
docker tag xenial_cmake datosh/xenial_cmake:v3.9.4
docker images
docker push datosh/xenial_cmake:v3.9.4
```

I feel the name `tag` is quite overloaded in the docker context. Make sure
to create 1-2 simple images like this to get the hang of it.

In the next part we will extent our newly created image by adding a modern
compiler: Clang 5.0.0.
