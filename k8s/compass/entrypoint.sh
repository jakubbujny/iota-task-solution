#!/usr/bin/env bash

set -e

mkdir -p /layers

cd /layers
aws s3 cp --recursive s3://iota-solution-s3-layers .

ls -lah /data

cd /
[[ $(ls -lah /data | wc -l) -gt 4 ]] java -jar /coordinator_deploy.jar \
	-layers /layers \
	-statePath /data/compass.state \
	-sigMode CURLP27 \
	-powMode CURLP81 \
	-mwm 7 \
	-security 1 \
	-seed AITTDKCFUO9UPAFEAUUHYV9Y9LHGAZ9HMMFSDNVHQGFGIUEADK9RMGSZXXOFN9XEODJBCNK9EFZNETBRC \
	-tick 90000 \
	-host http://iri-03:14265 \
	-broadcast


java -jar /coordinator_deploy.jar \
	-layers /layers \
	-statePath /data/compass.state \
	-sigMode CURLP27 \
	-powMode CURLP81 \
	-mwm 7 \
	-security 1 \
	-seed AITTDKCFUO9UPAFEAUUHYV9Y9LHGAZ9HMMFSDNVHQGFGIUEADK9RMGSZXXOFN9XEODJBCNK9EFZNETBRC \
	-tick 90000 \
	-host http://iri-03:14265 \
	-broadcast
    -bootstrap