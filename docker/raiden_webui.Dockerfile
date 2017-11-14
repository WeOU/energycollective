FROM ubuntu:xenial

MAINTAINER Pierre-Elouan Rethore <rethore@weou.org>

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 923F6CA9 \
 && echo "deb http://ppa.launchpad.net/ethereum/ethereum/ubuntu xenial main" \
       | tee -a /etc/apt/sources.list.d/ethereum.list

RUN apt-get update -y \
 && apt-get dist-upgrade -y \
 && apt-get install -y \
    automake \
    build-essential \
    git-core \
    libffi-dev \
    libgmp-dev \
    libssl-dev \
    libtool \
    pkg-config \
    python-dev \
    python-pip \
    solc \
 && rm -rf /var/lib/apt/lists/*

## Install latest version of NPM (Needed for the raiden webUI)
RUN apt-get update -y \
 && apt-get install -y curl \
 && pip install --upgrade pip \
 && pip install nodeenv \
 && curl -sL https://deb.nodesource.com/setup_6.x | bash - \
 && apt-get install -y nodejs \
 && npm  update npm -g

## Raiden tag number is passed as an argument from the docker compose page
ARG RAIDEN_TAG


## Install Raiden from git repo
RUN git clone https://github.com/raiden-network/raiden.git /apps/raiden \
 && cd /apps/raiden \
 && git checkout $RAIDEN_TAG

 
WORKDIR /apps/raiden

COPY settings.py /apps/raiden/raiden/

RUN pip install --upgrade -r requirements.txt \
 && python setup.py develop \
 && python setup.py compile_webui


EXPOSE 40001/udp
EXPOSE 5001

ENTRYPOINT ["raiden"]
