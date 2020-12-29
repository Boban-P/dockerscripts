FROM bb526/vscode:latest

LABEL maintainer="Boban Pulinchery <boban@ecodiver.in>"

USER root

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends python3 \
    && rm -rf /var/lib/apt/lists/*

USER developer
