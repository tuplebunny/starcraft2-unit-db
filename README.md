## Starcraft 2 Unit Database

* Data acquired from battle.net
* SQL and JSON format
* Learn SQL while enjoying Starcraft

### Starcraft and SQL, and match made in heaven

I'm merging 2 passions into 1!

I remember spending hours on the shareware version of the original Starcraft. Multiplayer was 1 map, 1 race. I remember the first time I saw an opponent build more-than-1 barracks. "Of course!" Starcraft as-a-sport has reinvigorated my interest, not in playing the game so much, but in supporting the game's eco-system, in whatever way I can.

SQL has been a patient sweet-heart. For years I misunderstood and therefore misused relational-databases. Today, SQL and I have a great relationship, and we've made a home inside Postgres.

### Requirements

* Ruby 2+
* Ruby Gem Nokogiri
* Ruby Gem PG
* PostgreSQL

### Development Status

To-do:

* Acquire remaining 2/3 unit data available via battle.net
* Manually augment acquired data to include number-of-hits (why this isn't on b.net I dunno)
* Provide Rails application that provides graphs of included SQL-queries
* Write more SQL-queries

Accomplished:

* Write version 1
* Acquire about 1/3 unit data available via battle.net
* Write script to push data into PostgreSQL
* Write basic SQL-queries against acquired data
