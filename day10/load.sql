drop table if exists day10, day10_moves;

create table day10 (
  id serial not null,
  x int not null,
  y int not null,
  v_x int not null,
  v_y int not null
);

create table day10_moves (
  moves int not null
);

insert into day10_moves values (0);

\copy day10 (x, y, v_x, v_y) from program './load.bash' delimiter ' ';

-- get the points of light close to each other
with min_moves_for_x as (
  select max((second.x - first.x) / (first.v_x - second.v_x)) as min_moves_for_x
  from day10 as first cross join day10 as second
  where first.v_x <> second.v_x
),
min_moves_for_y as (
  select max((second.y - first.y) / (first.v_y - second.v_y)) as min_moves_for_y
  from day10 as first cross join day10 as second
  where first.v_y <> second.v_y
),
min_moves as (
  select greatest(min_moves_for_x - 200, min_moves_for_y - 200, 0) as min_moves
  from min_moves_for_x cross join min_moves_for_y
),
update_moves as (
  update day10_moves set moves = min_moves from min_moves
)
update day10
set
  x = x + min_moves.min_moves * v_x,
  y = y + min_moves.min_moves * v_y
from min_moves;
