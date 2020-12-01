FROM debian:stable

MAINTAINER Boban Pulinchery <boban@ecodiver.in>

ARG CODE_FILE
ARG CODE_URL

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
                   git \
                   wget \
                   ca-certificates \
                   libx11-xcb1 \
                   libasound2 \
    && wget -O "/${CODE_FILE}" "${CODE_URL}" \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y "/${CODE_FILE}" \
    && rm "/${CODE_FILE}" \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -ms /bin/bash developer

COPY docker-entry.sh /

ENV HOME /home/developer
WORKDIR /home/developer
USER developer
ENV SHELL /bin/bash

ENTRYPOINT ["/docker-entry.sh"]

CMD ["code", "-w", "/home/developer"]
