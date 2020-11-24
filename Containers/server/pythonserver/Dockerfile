FROM debian:stable

MAINTAINER Boban Pulinchery <boban@ecodiver.in>

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
                   python3 python3-pip \
                   procps \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3 0 \
    && update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 0 \
    && pip install pip --upgrade \
    && pip install wheel \
    && pip install daphne uvicorn hypercorn \
    && rm -rf /var/lib/apt/lists/*


# default values; see:startup.sh

ENV LISTEN_PORT=8000


COPY data /

EXPOSE 8000

ENTRYPOINT ["/usr/sbin/entrypoint.sh"]

CMD ["daphne" , "--bind", "0.0.0.0"]
