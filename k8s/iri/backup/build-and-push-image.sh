#!/usr/bin/env bash

docker build -t digitalrasta/backup:aws-11 .

docker push digitalrasta/backup:aws-11