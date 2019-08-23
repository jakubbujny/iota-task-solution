#!/usr/bin/env bash

today=`date '+%Y_%m_%d__%H_%M_%S'`;

tar -zcf /data ${today}.tgz

aws s3 cp ${today}.tgz s3://iota-solution-s3-backup