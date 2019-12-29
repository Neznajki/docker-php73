#!/bin/bash

docker build -t neznajki/docker-php73 .
docker push neznajki/docker-php73:latest
