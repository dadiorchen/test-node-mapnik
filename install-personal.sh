#!/bin/bash
set -e
echo "start at `date`"
# Set up build environment
apt install -y sudo
sudo apt-get install -y software-properties-common
sudo add-apt-repository universe  # provides libboost-regex-dev, libboost-python-dev, libgdal-dev, postgis
sudo apt -y update
sudo apt -y upgrade
sudo DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
    build-essential clang python python-dev \
    libicu-dev \
    zlib1g-dev \
    libharfbuzz-dev \
    libfreetype6 libfreetype6-dev \
    libxml2 libxml2-dev \
    libpng-dev libjpeg-dev \
    postgresql libpq-dev \
    postgresql-10-postgis-2.4 postgresql-10-postgis-2.4-scripts \
    libgdal-dev libproj-dev \
    libboost-filesystem-dev \
    libboost-system-dev \
    libboost-regex-dev \
    libboost-program-options-dev \
    libboost-python-dev \
    libboost-thread-dev \
    libssl-dev  # for node to compile against

# Node with shared openssl (would bundle 1.0, system libpq links against 1.1)
#NODE_VERSION=v8.11.3
#wget https://nodejs.org/dist/$NODE_VERSION/node-$NODE_VERSION.tar.gz
#tar xf node-$NODE_VERSION.tar.gz
#cd node-$NODE_VERSION
#./configure --shared-openssl
#make -j4

#cat >> ~/.profile <<EOF
#export NODEJS_HOME=/usr/local/lib/nodejs/node-$NODE_VERSION/bin
#export PATH=\$NODEJS_HOME:\$PATH
#EOF
#. ~/.profile

# Build mapnik
cd ~
rm -rf mapnik
git clone https://github.com/mapnik/mapnik.git
cd mapnik 
git checkout 434511c  # commit id referenced by node-mapnik/package.json->mapnik_version
# git checkout v3.0.x  # would work with node-mapnik 3.7.2
git submodule update --init
rm -rf config.py
./configure
JOBS=2 make
sudo make install

# Check
mapnik-config -v

# Test
cd ~
rm -rf test-project
mkdir test-project
cd test-project

#sudo -S -u postgres psql -c 'create role tom with superuser login;'
#createdb test
#psql -c "create user test with login password 'test';" -d test
#psql -c 'grant all on database test to test;' -d test
#psql -c 'create extension postgis;' -d test
#psql -c 'create table test( geom geometry(geometry, 3857) );' -d test -U test

cat > package.json <<EOF
{
    "dependencies": {
        "mapnik": "^4.0.0"  
    }
}
EOF
# note: node-mapnik version "^3.7.2" works against mapnik v3.0.x branch

npm i --build-from-source=mapnik

cat > index.js <<EOF
const mapnik = require('mapnik')

console.log(process.env.PGSSLMODE)

mapnik.register_default_input_plugins()

new mapnik.Datasource({
    'type': 'postgis',
    'host': 'localhost',
    'dbname': 'test',
    'user': 'test',
    'password': 'test',
    'port': 5432,
    'table': 'test',
    'geometry_field': 'geom',
    'extent': '-20005048,-9039211,19907487,17096598'
})
EOF

node index.js
PGSSLMODE=require node index.js
