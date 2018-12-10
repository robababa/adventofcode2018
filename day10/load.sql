drop table if exists day10;

create table day10 (
  id serial not null,
  x int not null,
  y int not null,
  v_x int not null,
  v_y int not null
);

\copy day10 (x, y, v_x, v_y) from program './load.bash' delimiter ' ';

