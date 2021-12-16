## Overview

**NOTE: I USE THIS FOR MY HOMELAB SERVERS.** Your mileage may vary.

- ubuntu focal (20.04) base image
- `steam` user and user home created (`1000:1000` at `/home/steam`)
- timezone is set to America/Chicago
- enUS.UTF8 locale
- `steamcmd` is symlinked to `/usr/bin/steamcmd`

## Simple usage

Extend this base image with:

```
FROM nhalase/steamcmd:latest
USER 1000:1000
WORKDIR /home/steam
# e.g., RUN steamcmd +quit
```

## Packages

```
tzdata
ntp
locales
xz-utils
lsof
ca-certificates
curl
wget
file
tar
bzip2
gzip
unzip
binutils
bc
jq
tmux
netcat
lib32gcc1
lib32stdc++6
steamcmd
```
