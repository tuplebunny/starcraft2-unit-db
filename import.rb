require 'pg'
require 'json'

data = JSON.parse(open('sc2-data.json').read)

pg = PG.connect(dbname: 'sc2', host: 'localhost', user: 'korzybski')

data.each_pair do |unit_name, unit_data|
  puts %{Importing #{unit_name}}
  pg.exec('insert into sc2_units (race, name, data) values ($1, $2, $3)', [unit_data['race'], unit_name, unit_data.to_json])
end
