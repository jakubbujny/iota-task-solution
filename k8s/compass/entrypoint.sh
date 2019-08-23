#!/usr/bin/env bash

set -x

mkdir -p /layers

cd /layers
aws s3 cp --recursive s3://iota-solution-s3-layers .


cd /


rm -r /data/lost+found

ls -lah /data

if [[ $(ls -lah /data | wc -l) -gt 3 ]]; then
    java -jar /coordinator_deploy.jar -layers /layers -statePath /data/compass.state  -sigMode CURLP27 -powMode CURLP81 -mwm 7 -security 1 -seed AITTDKCFUO9UPAFEAUUHYV9Y9LHGAZ9HMMFSDNVHQGFGIUEADK9RMGSZXXOFN9XEODJBCNK9EFZNETBRC -tick 90000 -host http://iri-03:14265 -broadcast
else
    java -jar /coordinator_deploy.jar -layers /layers -statePath /data/compass.state  -sigMode CURLP27 -powMode CURLP81 -mwm 7 -security 1 -seed AITTDKCFUO9UPAFEAUUHYV9Y9LHGAZ9HMMFSDNVHQGFGIUEADK9RMGSZXXOFN9XEODJBCNK9EFZNETBRC -tick 90000 -host http://iri-03:14265 -broadcast -bootstrap
fi