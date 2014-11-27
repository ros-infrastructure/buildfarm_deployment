#!/bin/bash

set -o errexit;

docker build -t slave slave/
docker build -t master master/
docker build -t repo repo/
