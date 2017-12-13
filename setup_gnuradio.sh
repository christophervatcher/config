#!/bin/sh
sudo apt update
sudo apt upgrade --purge
sudo apt autoremove --purge

sudo apt install \
    vim \
    tree \
    exfat-fuse \
    exfat-utils

sudo apt install \
    python \
    python-pip \
    python-wheel \
    python3 \
    python3-pip \
    python3-wheel

pip install -U PyBOMBS
pybombs recipes add gr-recipes git+https://github.com/gnuradio/gr-recipes.git
pybombs recipes add gr-etcetera git+https://github.com/gnuradio/gr-etcetera.git
pybombs prefix init -a default gnuradio.env -R gnuradio-default #--virtualenv

#pybombs run gnuradio-companion
pybombs install gr-ieee-80211
pybombs install gr-ieee-802154

#git clone --recursive git://github.com/EttusResearch/uhd.git uhd.git
