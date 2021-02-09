const mapnik = require('mapnik')

console.log(process.env.PGSSLMODE)

mapnik.register_default_input_plugins()

new mapnik.Datasource({
      'type': 'postgis',
      'host': 'db-postgresql-sfo2-nextgen-do-user-1067699-0.db.ondigitalocean.com',
      'dbname': 'treetracker_dev',
      'user': 'doadmin',
      'password': 'l5al4hwte8qmj6x8',
      'port': 25060,
      'table': 'test',
      'geometry_field': 'geom',
      'extent': '-20005048,-9039211,19907487,17096598'
})

//POSTGRES_HOST=db-postgresql-sfo2-nextgen-do-user-1067699-0.db.ondigitalocean.com
//POSTGRES_PORT=25060
//POSTGRES_USER=doadmin
//POSTGRES_PASSWORD=l5al4hwte8qmj6x8
//POSTGRES_DATABASE=treetracker_dev
//NODE_PORT=8000
