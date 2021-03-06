FROM ubuntu:latest

LABEL maintainer="Yan siyu<siyu.yan@visenze.com>"

ENV LC_ALL=C
ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true

RUN groupadd --gid 1000 node \
  && useradd --uid 1000 --gid node --shell /bin/bash --create-home node


RUN apt-get -qqy update
RUN apt-get -qqy install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
RUN curl -sS -o - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list
RUN echo "deb http://archive.ubuntu.com/ubuntu xenial main universe\n" > /etc/apt/sources.list \
  && echo "deb http://archive.ubuntu.com/ubuntu xenial-updates main universe\n" >> /etc/apt/sources.list \
  && echo "deb http://security.ubuntu.com/ubuntu xenial-security main universe\n" >> /etc/apt/sources.list
RUN apt-get -qqy update

ENV BUILD_PACKAGES ca-certificates openssl gzip tar

ADD https://dl.bintray.com/qameta/generic/io/qameta/allure/allure/2.6.0/allure-2.6.0.tgz .
RUN mkdir -p allure allure-results allure-report allure-config allure-history && \
    update-ca-certificates && \ 
    tar -xzf allure-2.6.0.tgz -C ./ 

ENV PATH="/allure-2.6.0/bin:$PATH" ALLURE_CONFIG="/allure-config/allure.properties"


RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get -qqy --no-install-recommends install \
  nodejs \
  firefox \
  google-chrome-stable \
  openjdk-8-jre-headless \
  x11vnc \
  xvfb \
  xfonts-100dpi \
  xfonts-75dpi \
  xfonts-scalable \
  xfonts-cyrillic


RUN export DISPLAY=:99.0
RUN Xvfb :99 -shmem -screen 0 1366x768x16 &

WORKDIR /home/node
ADD package.json .
RUN chown node:node -R .
RUN chmod 777 -R .
RUN mkdir -p /home/node/_results_/allure-raw
RUN google-chrome --version
RUN firefox --version
RUN node --version
RUN npm --version

USER node
RUN npm install

ENTRYPOINT ["tail", "-f", "/dev/null"]

