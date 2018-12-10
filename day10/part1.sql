\pset border 0
\t on
\pset pager

-- keep looping until the lights are close enough to each other to read something
do
language plpgsql
$$
  declare
    close_enough boolean := false;
    x_distance int := 400;
    y_distance int := 400;
    loop_number int := 0;
  begin
    loop
      exit when close_enough;
      --update the display
      update day10 set x = x + v_x, y = y + v_y;
      select
        max(x) - min(x),
        max(y) - min(y),
        (max(y) - min(y) <= 10)
        into
          x_distance,
          y_distance,
          close_enough
      from day10;
      update day10_moves set moves = moves + 1;
      if loop_number % 100 = 0
        then
          raise notice 'x_distance = % and y_distance = %', x_distance, y_distance;
      end if;
      loop_number = loop_number + 1;
    end loop;
  end;
$$
;

-- show the display
with
  x_range as (select min(x) as min_x, max(x) as max_x from day10),
  y_range as (select min(y) as min_y, max(y) as max_y from day10),
  x_series as (select generate_series(min_x, max_x, 1) as x from x_range),
  y_series as (select generate_series(min_y, max_y, 1) as y from y_range),
  full_range as (select x, y from x_series cross join y_series)
select
  distinct
  full_range.y,
  full_range.x,
  case when day10.id is not null then '#' else ' ' end as mark
from
  full_range left join day10
                       on full_range.x = day10.x and full_range.y = day10.y
order by full_range.y, full_range.x \crosstabview
