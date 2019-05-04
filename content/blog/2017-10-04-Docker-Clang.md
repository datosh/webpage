---
title: Docker Image with Clang 5.0.0
description: Setting up a Docker Image with Clang 5.0.0
date: 2017-10-04 17:00:00
categories:
 - tutorial
tags:
 - Continuous Integration
 - Docker
 - CMake
---

## Docker + Clang

In the previous article we saw how to use a Docker Base Image and add CMake to
it.

To make our base build system complete we also need a modern compiler. Since
the Clang/LLVM project comes with a lot of nice tools, which we will also use
later on (clang-format, clang-tidy, miscellaneous sanitizers, ...), we will go
with Clang 5.0.0 here. If you like to use a different compiler (GCC, MSVC, ...)
feel free to swap it here.

All files used for this article can be found on my
[github](https://github.com/datosh/CppDev/tree/master/Container/20_Clang).

If you just want to use the created Docker Image feel free to pull it from my
[Docker Hub](https://hub.docker.com/r/datosh/xenial_clang/)

### Dockerfile

As we learned in the previous article, the Dockerfile defines how a new Docker
Image is created.

In this
[Dockerfile](https://github.com/datosh/CppDev/blob/master/Container/20_Clang/Dockerfile)
we use our previously created Docker Image as a starting point.
```sh
FROM datosh/xenial_cmake:v3.9.4
```

Other than that, the commands are the same. We specify our working directory, 
and copy our installation script. We use our package manager to install Clang's
installation dependencies, and then actually run our installation script.
Finally we clean up all temporary files.

If anything of this is new to you, please refer to the previous article in this
series.

### Building Clang

Please refer to the `build_clang.sh` script for all necessary steps.
Since the script is quite long I will only go over the interesting parts.

If you need more information
[Clang's: Getting Started](https://llvm.org/docs/GettingStarted.html)
documentation and
[this Stackoverflow Post](https://stackoverflow.com/a/25840107/2306355)
have helped me to put this script together.

After checking out the correct repositories into each other, and creating a
build directory we use
`cmake -DCMAKE_BUILD_TYPE=Release -DLLVM_TARGETS_TO_BUILD=X86 ../llvm`
to generate our build system. The default build type is `debug`, and since 
C++ build times can be excruciatingly long, we should really make sure we get
all the speed we can. We also use the `LLVM_TARGETS_TO_BUILD` to limit our
targets to only `X86`. This saved me about 500MB in Docker Image footprint. If
you need more targets, e.g., for cross compilation, add them there as needed.

Also make sure that you postfix all `make`'s with `-j4` or more to take
advantage of multiple cores when building. Building Clang from source takes
about an hour, depending on your hardware and the targets & tools you want to
build.

The second half of the script takes care of checking out Clang's implementation
of the standard library (libcxx), and compiling & installing it. This is
important, since upgrading your compiler is only half of the story when working
with C++. You also need to upgrade your standard library to get the new
library features.

### Running It

Now that everything is in place we need to actually trigger the creation of the
new Docker Image. All necessary steps can be found in the `run.sh` file, and
are the same as in the previous article.


