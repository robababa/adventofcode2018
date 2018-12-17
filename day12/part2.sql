do
  language plpgsql
    $$
    declare
    begin
      for gen in 21..200 loop
        perform day12_create_next_generation(gen);
        perform day12_update_next_generation(gen);
      end loop;
    end;
    $$
;

with source as (
  select
  generation, sum(position) as value
  from
  day12
  where
  state = '#'
  group by generation
  order by generation
  )
select
       generation,
       value,
       lag(value) over (order by generation) as prev,
       value - lag(value) over (order by generation) as delta
from source;

select 7557::bigint + (50000000000::bigint - 101::bigint) * 59::bigint as part2_answer;

