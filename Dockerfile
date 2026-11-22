FROM ruby:3.4

WORKDIR /usr/src/app

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y default-jre