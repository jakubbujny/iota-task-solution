#!/usr/bin/env bash

aws s3 cp --recursive . s3://iota-solution-s3-layers/ --exclude "*.sh"