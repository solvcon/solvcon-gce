#!/bin/bash

URL=https://dl.google.com/dl/cloudsdk/channels/rapid/install_google_cloud_sdk.bash

function download {
  scratch=$(mktemp -d -t gce.tmp.XXXXXXXXXX) || exit
  script_file=$scratch/install_google_cloud_sdk.bash

  echo "Downloading Google Cloud SDK install script: $URL"
  curl -# $URL > $script_file || exit
  chmod 775 $script_file

  echo "Running install script from: $script_file"
  env CLOUDSDK_PYTHON=/usr/bin/python2.7 $script_file \
    --install-dir=${HOME}/opt --disable-prompts
  # recover from the damage done by install_google_cloud_sdk.bash
  if [ -f ~/.bashrc.backup ]; then
    mv -f ~/.bashrc.backup ~/.bashrc
  fi
}

download

# vim: set et nobomb fenc=utf8 ft=sh ff=unix sw=2 ts=2:
