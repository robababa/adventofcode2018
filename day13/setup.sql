drop table if exists day13, day13_grid, day13_cart;

create table day13 (
  id serial not null primary key,
  line text not null
);

\copy day13 (line) from program 'sed ''s/\\/\\\\/g'' ./input.txt';

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
insert into day13_grid (y, track, x)
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

-- set up the functions
create or replace function day13_spots() returns bigint
  language sql
as
$$
select count(distinct(x,y)) from day13_cart;
$$
;

create or replace function day13_next_turn(current_turn text) returns text
  language sql
as
$$
select
  case current_turn
    when 'left' then 'straight'
    when 'straight' then 'right'
    when 'right' then 'left'
    end;
$$
;

create or replace function day13_next_direction(next_x int, next_y int, current_direction text, current_turn text) returns text
  language sql
as
$$
with next_track as (
  select * from day13_grid where x = next_x and y = next_y
)
select
  case track
    when '+' then
      case
        when current_turn = 'straight' then current_direction
        when current_turn = 'left' and current_direction = 'N' then 'W'
        when current_turn = 'left' and current_direction = 'W' then 'S'
        when current_turn = 'left' and current_direction = 'S' then 'E'
        when current_turn = 'left' and current_direction = 'E' then 'N'
        when current_turn = 'right' and current_direction = 'N' then 'E'
        when current_turn = 'right' and current_direction = 'E' then 'S'
        when current_turn = 'right' and current_direction = 'S' then 'W'
        when current_turn = 'right' and current_direction = 'W' then 'N'
        end
    when '/' then
      case current_direction
        when 'N' then 'E'
        when 'E' then 'N'
        when 'S' then 'W'
        when 'W' then 'S'
        end
    when '\' then
      case current_direction
        when 'N' then 'W'
        when 'W' then 'N'
        when 'S' then 'E'
        when 'E' then 'S'
        end
    else -- track is - or | so continue in same direction
      current_direction
    end
from next_track;
$$
;

create or replace function day13_move_cart(cart day13_cart) returns void
  language sql
as
$$
with next_points as (
  select
    case cart.direction
      when 'E' then cart.x + 1
      when 'W' then cart.x - 1
      else cart.x
      end as x,
    case cart.direction
      when 'S' then cart.y + 1
      when 'N' then cart.y - 1
      else cart.y
      end as y
)
update day13_cart
set
  (x, y, direction, next_turn) =
    (
      select
        next_points.x,
        next_points.y,
        day13_next_direction(next_points.x, next_points.y, cart.direction, cart.next_turn),
        case
          when (select track from day13_grid as g inner join next_points as n on g.x = n.x and g.y = n.y) = '+'
            then day13_next_turn(next_turn)
          else next_turn
          end
    )
from next_points
where
    day13_cart.id = cart.id;
$$
;
