drop table if exists day11_expansion;

-- 90,39,210 is wrong

create table day11_expansion (
  x int not null,
  y int not null,
  expansion_level int not null,
  expansion_value int not null,
  constraint pk_day11_expansion primary key (x,y,expansion_level) --,
  --constraint fk_day11_expansion__x_y foreign key (x, y) references day11 (x, y)
);

do
language plpgsql
$$
  begin
    -- the initial "expansions" are just the coordinate values by themselves
    insert into day11_expansion (x, y, expansion_level, expansion_value) select x, y, 0, value from day11;

    -- each time we expand, we go one further to the right on the coordinate's row and
    -- one further down in the coordinate's column
    for i in 1..299 loop
      raise notice 'expanding to level %', i;
      insert into day11_expansion (x, y, expansion_level, expansion_value)
      select
      e.x, e.y, e.expansion_level + 1, e.expansion_value + x_to_the_right.expansion_value + y_going_down.expansion_value
      from
        day11_expansion as e
          inner join
            day11_expansion as x_to_the_right on
              x_to_the_right.y = e.y and
              x_to_the_right.x = e.x + i and
              x_to_the_right.expansion_level = 0
          inner join
            day11_expansion as y_going_down on
              y_going_down.x = e.x and
              y_going_down.y = e.y + i and
              y_going_down.expansion_level = 0
      where
        e.expansion_level = i - 1;
    end loop;
  end;
$$
;

create table day11_fuel_cells (
  x int not null,
  y int not null,
  expansion_level int not null,
  expansion_value int not null
);

insert into day11_fuel_cells
(x, y, expansion_level, expansion_value)
select
from
day11_expansion


select
  starting_point.x as starting_x,
    starting_point.y as starting_y,
    min(expansions.x) as actual_x,
    min(expansions.y) as actual_y,
    max(expansions.expansion_level) + 1 as actual_expansion_level,
    sum(expansions.expansion_value) as total_value
from
  day11_expansion as starting_point
inner join
    day11_expansion as expansions
on
starting_point.x >= expansions.x and
starting_point.y >= expansions.y and
starting_point.x - expansions.x = starting_point.y - expansions.y
where
starting_point.expansion_value = 0
group by
starting_point.x, starting_point.y
order by
sum(expansions.expansion_value) desc
limit 10;
