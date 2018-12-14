do
  language plpgsql
    $$
    declare
    begin
      for gen in 21..100 loop
        perform day12_create_next_generation(gen);
        perform day12_update_next_generation(gen);
      end loop;
    end;
    $$
;

-- 3832 is too high
select generation, sum(position)
from day12
where state = '#'
group by generation
order by generation;
