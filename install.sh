#!/bin/bash

###########################################################
# install.sh - Install the home directory files
#       into current user's home dir.
#
#  Will replace any existing files with .${FNAME}.orig
#######################################################

THIS_DIR="$(dirname ${BASH_SOURCE[0]})"
THIS_DIR="$(realpath "${THIS_DIR}")"

cd "${HOME}"
#HOME="/tmp/home"
#cd /tmp/home

for fname in bash_profile bashrc pystartup screenrc vimrc;
do
    [ -f ".${fname}" ] && echo "Backing up '${HOME}/.${fname}' to '${HOME}/.${fname}.orig'..." && mv ".${fname}" ".${fname}.orig"
    
    echo "Installing '${THIS_DIR}/${fname}' -> '${HOME}/.${fname}'"
    cp -a "${THIS_DIR}/${fname}" ".${fname}"

done
