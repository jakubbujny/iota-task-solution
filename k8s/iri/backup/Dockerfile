FROM willfarrell/crontab

COPY config.json ${HOME_DIR}/

COPY run.sh /run.sh

RUN apk add python3-dev

RUN pip3 install awscli --upgrade

RUN aws --version