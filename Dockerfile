ARG ubuntu_version=focal
FROM ubuntu:${ubuntu_version} as base

ARG steam_uid=1000
ARG steam_gid=1000
ARG steam_user="steam"
ARG description="A base image for a SteamCMD based container"
ARG sources_list=multiverse.list
ARG packages_list=packages.list

LABEL nws.monster.stack.id=${ubuntu_version}
LABEL nws.monster.stack.user.name=${steam_user}
LABEL nws.monster.stack.user.uid=${steam_uid}
LABEL nws.monster.stack.user.gid=${steam_gid}
LABEL nws.monster.stack.description=${description}

USER root
WORKDIR /root

COPY ${sources_list} /etc/apt/sources.list.d/multiverse.list
COPY ${packages_list} /etc/apt/packages.list

RUN groupadd ${steam_user} --gid ${steam_gid} \
    && useradd --uid ${steam_uid} --gid ${steam_gid} -m -s /bin/bash ${steam_user}


FROM base as builder

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=America/Chicago \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_CTYPE="C" \
    LC_ALL=en_US.UTF-8

RUN echo steam steam/question select "I AGREE" | debconf-set-selections \
    && echo steam steam/license note '' | debconf-set-selections

RUN dpkg --add-architecture i386 && apt-get update && apt-get update && apt-get install -y \
    $(grep -vE "^\s*#" /etc/apt/packages.list | tr "\n" " ") \
    && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && update-locale LANG=en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

RUN ln -s /usr/games/steamcmd /usr/bin/steamcmd

RUN echo $TZ > /etc/timezone \
    && rm -f /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata


FROM builder as steamcmd

USER ${steam_uid}:${steam_gid}
WORKDIR /home/${steam_user}
