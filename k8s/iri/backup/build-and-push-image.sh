#!/usr/bin/env bash

docker build -t digitalrasta/backup:aws-10 .

docker push digitalrasta/backup:aws-10