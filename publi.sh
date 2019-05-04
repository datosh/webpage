#!/bin/sh

hugo

docker build -t webpage .
docker run --rm -p 8080:80 webpage