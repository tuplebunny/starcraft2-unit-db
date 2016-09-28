-- Unit-counts per race
select race, count(*) from sc2_units group by 1;

-- Top-5 highest-health units.
select race, name, data->'life' as life from sc2_units order by 3 desc limit 5;

-- Highest-health unit per race.
select
  race, max(life)
from
  (select race, name, (data->>'life')::integer as life from sc2_units) as r1
group by
  1
;

-- Highest-life unit for each race, e.g.:
-- {race, unit, life}
-- Low-High life for every race.



-- Low-Highs for each race...?
select
  race
  ,name
  ,first_value(life) over (partition by race order by life) as low
  ,last_value(life) over (partition by race order by life range between unbounded preceding and unbounded following) as high
from
  (select race, name, (data->>'life')::integer as life from sc2_units) as r1
;
