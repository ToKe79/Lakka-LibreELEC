#!/bin/bash

EXFATPATH=${1}

if [ -z "${EXFATPATH}" ]; then
  echo "${0}: no path provided! Aborting!"
  exit 1
fi

if [ ! -d ${EXFATPATH} ]; then
  echo "${0}: path '${EXFATPATH}' is not a folder!"
  exit 1
fi

if [ ! -w ${EXFATPATH} ]; then
  echo "${0}: path '${EXFATPATH}' is not writable!"
  exit 1
fi

RA_CONF_PATH=/storage/.config/retroarch
RA_CONF_FILE=retroarch.cfg
RA_CONF_DEF=/etc/${RA_CONF_FILE}

# create folder structure on the EXFAT partition
for folder in 01_RetroArch/downloads \
              01_RetroArch/logfiles \
              01_RetroArch/playlists \
              01_RetroArch/recordings \
              01_RetroArch/remappings \
              01_RetroArch/savefiles \
              01_RetroArch/savestates \
              01_RetroArch/screenshots \
              01_RetroArch/thumbnails \
              02_Transfer/assets \
              02_Transfer/cores \
              02_Transfer/database \
              02_Transfer/joypads \
              02_Transfer/overlays \
              02_Transfer/shaders \
              02_Transfer/system \
              03_Transfer_done ; do
  mkdir -p ${EXFATPATH}/${_path}
done

# replace paths in RetroArch config file
if [ ! -f ${RA_CONF_PATH}/${RA_CONF_FILE} ]; then
  [ ! -d ${RA_CONF_PATH} ] && mkdir ${RA_CONF_PATH}
  cp ${RA_CONF_DEF} ${RA_CONF_PATH}/${RA_CONF_FILE}
fi

sed -i ${RA_CONF_PATH}/${RA_CONF_FILE} \
    -e 's|/roms/downloads"|/downloads"|g' \
    -e 's|"~/roms"|"/storage/roms/EXFAT"|g' \
    -e 's|"/storage/|"/storage/roms/EXFAT/01_RetroArch/|g'

