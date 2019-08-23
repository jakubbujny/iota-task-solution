#!/usr/bin/env bash

set -x

today=`date '+%Y_%m_%d__%H_%M_%S'`;

cd /data

ls -lah

tar -zcf $HOME/${MY_POD_NAME}-${today}.tgz --exclude='./lost+found' .

aws s3 cp $HOME/${MY_POD_NAME}-${today}.tgz s3://iota-solution-s3-backup

rm $HOME/${MY_POD_NAME}-${today}.tgz