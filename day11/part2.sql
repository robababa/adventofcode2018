drop table if exists day11_expansion;

create table day11_expansion (
  x int not null,
  y int not null,
  expansion_level int not null,
  expansion_value int not null,
  upper_left_x int not null,
  upper_left_y int not null,
  corner_shift int not null,
  constraint pk_day11_expansion primary key (x,y,expansion_level),
  constraint check_day11_expansion__shift check (corner_shift = x - y)
);

-- this next step takes 6.5 minutes on my laptop, on battery power
do
language plpgsql
$$
  begin
    -- the initial "expansions" are just the coordinate values by themselves
    insert into day11_expansion
      (x, y, expansion_level, expansion_value, upper_left_x, upper_left_y, corner_shift)
      select x, y, 1, value, x, y, x - y from day11;

    -- each time we expand, we go one further to the left on the coordinate's row and
    -- one further up in the coordinate's column
    for i in 2..300 loop
      raise notice 'expanding to level %', i;
      insert into day11_expansion
      (
        x, y, expansion_level, expansion_value,
        upper_left_x, upper_left_y, corner_shift
      )
      select
        e.x, e.y, e.expansion_level + 1, e.expansion_value + x_to_the_left.expansion_value + y_going_up.expansion_value,
          x_to_the_left.x, y_going_up.y, e.x - e.y
      from
        day11_expansion as e
          inner join
            day11_expansion as x_to_the_left on
              x_to_the_left.y = e.y and
              x_to_the_left.x = e.x - i + 1 and
              x_to_the_left.expansion_level = 1
          inner join
            day11_expansion as y_going_up on
              y_going_up.x = e.x and
              y_going_up.y = e.y - i + 1 and
              y_going_up.expansion_level = 1
      where
        e.expansion_level = i - 1;
    end loop;
  end;
$$
;

-- 25 seconds
create index day11_expansion_idx on day11_expansion
  (corner_shift, upper_left_x, expansion_level, upper_left_y, expansion_value);

-- 1 minute 24 seconds
with source as
       (
         select
           corner_shift,
           upper_left_x,
           upper_left_y,
           last_value(expansion_level) over
             (
             partition by corner_shift, upper_left_x
             order by expansion_level
             rows between unbounded preceding and current row
             ) as expansion_level,
           sum(expansion_value) over
             (
             partition by corner_shift, upper_left_x
             order by expansion_level
             rows between unbounded preceding and current row
             ) as box_total
         from day11_expansion
         order by corner_shift, upper_left_x, expansion_level
       )
select upper_left_x, upper_left_y, expansion_level, box_total
from source
order by box_total desc
limit 10;
