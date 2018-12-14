drop table if exists day13, day13_grid, day13_cart;

create table day13 (
  id serial not null primary key,
  line text not null
);

\copy day13 (line) from program 'sed ''s/\\/\\\\/g'' ./sample_input.txt';

update day13 set id = id - 1;

create table day13_grid (
  x int not null,
  y int not null,
  track text not null,
  constraint pk_day13_grid primary key (x, y)
);

with source as (
  select id, regexp_split_to_table(line, '') as track from day13
)
insert into day13_grid (x, track, y)
select id, track, row_number() over (partition by id) - 1 from source;

create table day13_cart (
  id serial not null,
  x int not null,
  y int not null,
  direction text not null check (direction in ('N','S','E','W')),
  next_turn text not null default 'left' check (next_turn in ('left', 'straight', 'right')),
  constraint uk_day13_cart_x_y unique (x, y)
);

with
  cart_source as
  (
    select x, y, track from day13_grid where track in ('^','v','>','<')
  )
insert into day13_cart (x, y, direction)
select
  x,
  y,
  case track
  when '^' then 'N'
  when 'v' then 'S'
  when '>' then 'E'
  when '<' then 'W'
end
from cart_source;


update day13_grid
set track = case track
  when '^' then '|'
  when 'v' then '|'
  when '>' then '-'
  when '<' then '-'
end
where track in ('^','v','>','<');


delete from day13_grid where track = ' ';

-- now that we've updated our track into its final form, add the check constraint
alter table day13_grid add constraint check_track check (track in ('|', '-', '\', '/', '+'));

-- now the track and the carts are all set up
