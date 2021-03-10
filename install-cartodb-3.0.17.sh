#!/bin/bash
set -e
echo "start at `date`"
#apt update
#apt install -y sudo git
#sudo apt-get update -y
#sudo apt-get upgrade -y
## On some systems just:
#sudo apt-get install -y \
#  libboost-filesystem-dev \
#  libboost-program-options-dev \
#  libboost-python-dev libboost-regex-dev \
#  libboost-system-dev libboost-thread-dev \
#
## get a build environment going...
#sudo apt-get install -y \
#  libicu-dev \
#  python-dev libxml2 libxml2-dev \
#  libfreetype6 libfreetype6-dev \
#  libharfbuzz-dev \
#  libjpeg-dev \
#  libpng-dev \
#  libproj-dev \
#  libtiff-dev \
#  libcairo2-dev python-cairo-dev \
#  libcairomm-1.0-dev \
#  ttf-unifont ttf-dejavu ttf-dejavu-core ttf-dejavu-extra \
#  build-essential python-nose \
#  libgdal-dev python-gdal
#
#sudo DEBIAN_FRONTEND=noninteractive apt  install -y postgresql-server-dev-9.5 postgresql-9.5 postgresql-contrib postgresql-9.5-postgis-scripts
#
#cd ~
#rm -rf mapnik
#git clone https://github.com/mapnik/mapnik --depth 10
#cd mapnik
#git fetch --all --tags
##git checkout tags/v3.0.15
##use version which is a bit newer then 3.0.15, it's 3.0.19 or so
#git checkout 2f28d98
#git submodule update --init
#./configure
#JOBS=2 make 
#sudo make install
#

cd ~
rm -rf node-mapnik
git clone https://github.com/dadiorchen/node-mapnik.git 
cd node-mapnik

make release_base

echo "finish node-mapnik"


echo "install green tile server"
cd ~
rm -rf treetracker-map-tile-server
git clone https://github.com/dadiorchen/treetracker-map-tile-server.git
cd treetracker-map-tile-server
npm i
#replace node mapnik module with local one, which is already build based on
#the local mapnik
mv node_modules/\@carto/mapnik/ node_modules/\@carto/mapnik.bak
ln -s ~/node-mapnik/ node_modules/\@carto/mapnik
npm test
echo "done!"




