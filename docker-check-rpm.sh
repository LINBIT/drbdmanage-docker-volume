#!/bin/sh

rpm -q --quiet docker
docker=$?
rpm -q --quiet docker-engine
dockerengine=$?

if [ "$docker" = "1" -a "$dockerengine" = "1" ]; then
	echo "Please install docker|docker-engine"
	/bin/false
fi
