FROM bb526/android:latest

LABEL maintainer="Boban Pulinchery <boban@ecodiver.in>"

USER root

ARG CODE_FILE
ARG CODE_URL

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
                   wget ca-certificates gnupg \
                   git \
                   libx11-xcb1 \
                   libasound2 \
                   nodejs \
    && wget -O "/${CODE_FILE}" "${CODE_URL}" \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y "/${CODE_FILE}" \
    && rm "/${CODE_FILE}" \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends  npm \
    && npm i -g expo-cli \
    && npm i -g react-native-cli \
    && rm -rf /var/lib/apt/lists/*

USER developer
