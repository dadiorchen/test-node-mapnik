#!/bin/bash
set -e
echo "start at `date`"
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

sudo DEBIAN_FRONTEND=noninteractive apt  install -y postgresql-10-postgis-2.4 postgresql-10-postgis-2.4-scripts 

cd ~
rm -rf mapnik
git clone https://github.com/mapnik/mapnik --depth 10
cd mapnik
git fetch --all --tags
#git checkout tags/v3.0.15
#use version which is a bit newer then 3.0.15, it's 3.0.19 or so
git checkout a408b0732eee32cbc9e508b0593e83d7b075128d
git submodule update --init
./configure
JOBS=2 make 
sudo make install


cd ~
rm -rf node-mapnik
git clone https://github.com/CartoDB/node-mapnik.git
cd node-mapnik

make release_base

cat > index.js <<EOF
const mapnik = require('.')

console.log(process.env.PGSSLMODE)

mapnik.register_default_input_plugins()

//const ds = new mapnik.Datasource({
//    'type': 'postgis',
//    'host': '172.17.0.3',
//    'dbname': 'postgres',
//    'user': 'postgres',
//    'password': 'mysecretpassword',
//    'port': 5432,
//    'table': 'trees',
//    'geometry_field': 'the_geom',
//    'extent': '-20005048,-9039211,19907487,17096598'
//})
console.log("db:", ds);
EOF

#node index.js
PGSSLMODE=require node index.js
