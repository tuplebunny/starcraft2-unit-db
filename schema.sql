create table sc2_units (
  race text
  ,name text
  ,data jsonb

  ,primary key (race, name)
);
