FROM ubuntu:22.04

RUN apt-get update && apt-get install -y sudo

COPY ./config ./config
COPY ./fonts ./fonts
COPY ./install.sh ./install.sh

ENTRYPOINT ["bash", "-i", "-c", "./install.sh && exec bash"]