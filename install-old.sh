#!/bin/bash
set -e
apt install -y sudo 
sudo apt-get update -y
sudo apt-get upgrade -y
# On some systems just:
sudo apt-get install -y \
  libboost-filesystem-dev \
  libboost-program-options-dev \
  libboost-python-dev libboost-regex-dev \
  libboost-system-dev libboost-thread-dev \

# get a build environment going...
sudo apt-get install -y \
  libicu-dev \
  python-dev libxml2 libxml2-dev \
  libfreetype6 libfreetype6-dev \
  libharfbuzz-dev \
  libjpeg-dev \
  libpng-dev \
  libproj-dev \
  libtiff-dev \
  libcairo2-dev python-cairo-dev \
  libcairomm-1.0-dev \
  ttf-unifont ttf-dejavu ttf-dejavu-core ttf-dejavu-extra \
  build-essential python-nose \
  libgdal-dev python-gdal

sudo DEBIAN_FRONTEND=noninteractive apt  install -y postgresql-server-dev-10 postgresql-10 postgresql-contrib postgresql-10-postgis-scripts

cd ~
rm -rf mapnik
git clone https://github.com/mapnik/mapnik --depth 10
cd mapnik
git submodule update --init
./configure
make 
sudo make install


cd ~
rm -rf test-project
mkdir -p test-project
cd test-project

cat > package.json <<EOF
{
    "dependencies": {
        "mapnik": "4.5.5"  
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
    'host': '172.17.0.3',
    'dbname': 'postgres',
    'user': 'postgres',
    'password': 'mysecretpassword',
    'port': 5432,
    'table': 'trees',
    'geometry_field': 'geom',
    'extent': '-20005048,-9039211,19907487,17096598'
})
EOF

node index.js
PGSSLMODE=require node index.js
