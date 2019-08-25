#!/usr/bin/env bash

set -x

echo "$@"

mkdir -p /layers

cd /layers
aws s3 cp --recursive s3://iota-solution-s3-layers .


cd /


rm -r /data/lost+found

ls -lah /data

if [[ $(ls -lah /data | wc -l) -gt 3 ]]; then
    java -jar /coordinator_deploy.jar "$@"
else
    java -jar /coordinator_deploy.jar -bootstrap "$@"
fi