#!/usr/bin/env bash

docker build -t digitalrasta/backup:aws-02 .

docker push digitalrasta/backup:aws-02