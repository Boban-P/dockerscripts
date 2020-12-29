FROM debian:stable

LABEL maintainer="Boban Pulinchery <boban@ecodiver.in>"

ARG KVM_GID
ARG LIBVIRT_GID

RUN addgroup --gid ${KVM_GID} kvm && \
    addgroup --gid ${LIBVIRT_GID} libvirt && \
    dpkg --add-architecture i386 && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
                   build-essential \
                   man-db \
                   openjdk-11-jdk \
                   openjdk-11-jre \
                   libc6:i386 \
                   libncurses5:i386 \
                   libstdc++6:i386 \
                   lib32z1 \
                   libbz2-1.0:i386 \
                   libxrender1 \
                   libvirt-daemon-system \
                   qemu-kvm \
                   libvirt-clients \
                   bridge-utils \
                   libxft2 \
                   libnotify4 libglu1 libqt5widgets5 xvfb \
                   libpulse0 libxcomposite1 libxcursor1 \
                   netcat \
                   git \
                   usbutils \
                   opensc \
                   fonts-smc \
                   wget \
                   sudo \
    && ln -s /android-studio/bin/studio.sh /usr/bin/android \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -ms /bin/bash developer \
    && adduser developer root \
    && adduser developer kvm \
    && adduser developer libvirt
#    echo "developer ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-developer && \
#    echo "Set disable_coredump false" >>/etc/sudo.conf && \

COPY entrypoint.sh data /



ENV ANDROID_EMULATOR_USE_SYSTEM_LIBS=1
ENV HOME /home/developer
WORKDIR /home/developer
USER developer

CMD ["android"]
ENTRYPOINT [ "/entrypoint.sh" ]
