#!/bin/sh -
docker start $(docker ps -a | grep kyle | awk '{print $NF}')
