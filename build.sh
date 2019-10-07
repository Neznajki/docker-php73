#!/bin/bash

docker build -t docker.pkg.github.com/neznajki/docker-php73/apache:latest .
docker push docker.pkg.github.com/neznajki/docker-php73/apache:latest
