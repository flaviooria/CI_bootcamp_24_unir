FROM jenkins/ssh-agent:latest-jdk21

USER root
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    git \
    curl

