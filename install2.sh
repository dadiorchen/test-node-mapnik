#!/bin/bash
set -e
## you might have to update your outdated clang
#apt install -y sudo
#sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
#sudo apt-get update -y
#sudo apt-get install -y gcc-6 g++-6 clang-3.9
#export CXX="clang++-3.9" && export CC="clang-3.9"
#
## install mapnik
#git clone https://github.com/mapnik/mapnik mapnik --depth 10
#cd mapnik
##git checkout c6fc956a7  # commit id referenced by node-mapnik/package.json->mapnik_version
#git submodule update --init
#sudo apt-get install -y python zlib1g-dev clang make pkg-config curl
#source bootstrap.sh
#./configure CUSTOM_CXXFLAGS="-D_GLIBCXX_USE_CXX11_ABI=0" CXX=${CXX} CC=${CC}
#JOBS=1 make
#make test
#sudo make install
#
## Check
#mapnik-config -v
#
## Test
#
##sudo -S -u postgres psql -c 'create role tom with superuser login;'
##createdb test
##psql -c "create user test with login password 'test';" -d test
##psql -c 'grant all on database test to test;' -d test
##psql -c 'create extension postgis;' -d test
##psql -c 'create table test( geom geometry(geometry, 3857) );' -d test -U test
#
cd ~
mkdir -p test-project
cd test-project

cat > package.json <<EOF
{
    "dependencies": {
        "mapnik": "latest"  
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
