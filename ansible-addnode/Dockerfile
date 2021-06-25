FROM nginx:alpine
MAINTAINER Poste Italiane

ENV SCRIPTS_PATH=/var/besu/scripts

# Install prerequisites for besu ansible role 
RUN apk add openjdk11 ansible jq yarn openssh sshpass unzip
     
RUN mkdir -p ${SCRIPTS_PATH}
RUN mkdir /root/.ssh
RUN alias python=python3

WORKDIR ${SCRIPTS_PATH}

# Container Environment Variables
ENV ANSIBLE_HOST_KEY_CHECKING=False

# Install additional ansible-galaxy requirements for this repository:
RUN echo ${SCRIPTS_PATH}
RUN ansible-galaxy collection install community.docker --ignore-errors

