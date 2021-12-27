FROM ghcr.io/nws-monster/ubuntu:latest as builder

ARG steam_uid=1001
ARG steam_gid=1001
ARG steam_user="steam"
ARG description="A simple SteamCMD image for use in nws.monster projects."
ARG packages_list=packages.list

LABEL nws.monster.stack.id=${ubuntu_version}
LABEL nws.monster.stack.user=${steam_user}
LABEL nws.monster.stack.user.uid=${steam_uid}
LABEL nws.monster.stack.user.gid=${steam_gid}
LABEL nws.monster.stack.description=${description}

USER root
WORKDIR /root

COPY ${packages_list} /tmp/packages.list

RUN groupadd ${steam_user} --gid ${steam_gid} \
    && useradd --uid ${steam_uid} --gid ${steam_gid} -m -s /bin/bash ${steam_user}

RUN echo steam steam/question select "I AGREE" | debconf-set-selections \
    && echo steam steam/license note '' | debconf-set-selections

RUN dpkg --add-architecture i386 \
    && sed -i "/^# deb .* multiverse$/ s/^# //" /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y \
    $(grep -vE "^\s*#" /tmp/packages.list | tr "\n" " ") \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/packages.list

RUN ln -s /usr/games/steamcmd /usr/bin/steamcmd

USER ${steam_uid}:${steam_gid}
WORKDIR /home/${steam_user}

CMD [ "/usr/bin/steamcmd" ]
