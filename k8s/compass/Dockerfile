FROM digitalrasta/compass:latest


RUN apt-get update && apt-get install -y python3 python3-pip

RUN pip3 install awscli --upgrade

RUN aws --version

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT /entrypoint.sh