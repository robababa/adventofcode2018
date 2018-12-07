drop table if exists day06, day06_grid;
drop function if exists day06_distance;

create table day06 (
  id serial not null unique,
  x int not null,
  y int not null
);

\copy day06 (x, y) from program './load.bash' delimiter ' ';

create or replace function day06_distance(p1 point, p2 point) returns int
language sql
immutable
as
$$
  select (abs(p1[0] - p2[0]) + abs(p1[1] - p2[1]))::int;
$$
;

create table day06_grid (
  id serial not null primary key,
  x int not null,
  y int not null,
  closest_point_id int null,
  constraint uk_day06_grid unique (x, y)

);

insert into day06_grid (x, y)
with
  x_limits as
    (select min(x) - 1 as min_x, max(x) + 1 as max_x from day06),
  y_limits as
    (select min(y) - 1 as min_y, max(y) + 1 as max_y from day06),
  x_values as
    (select generate_series(min_x, max_x, 1) as x from x_limits),
  y_values as
    (select generate_series(min_y, max_y, 1) as y from y_limits)
select
x, y
from
x_values cross join y_values;

do
$$
  declare
    affected int := 0;
    distance int := 0;
  begin
    loop
      with source as (
        select
          grid.id,
          min(day06.id) as min_id,
          max(day06.id) as max_id
        from
          day06
            cross join day06_grid as grid
        where
          grid.closest_point_id is null
          and
          day06_distance(point(day06.x, day06.y), point(grid.x, grid.y)) = distance
        group by grid.id
      )
      update day06_grid
      set
      closest_point_id = case when min_id = max_id then min_id else 0 end
      from
      source
      where
      day06_grid.id = source.id;

      get diagnostics affected := row_count;
      raise notice 'distance %, rows affected %', distance, affected;
      exit when affected = 0;
      distance := distance + 1;
    end loop;
  end;
$$
;

select x, y, closest_point_id from day06_grid order by x, y \crosstabview

with nearest_counts as (
  select day06.id, day06.x, day06.y, count(*) as nearest_count
  from
    day06
      inner join
      day06_grid as grid
      on
        day06.id = grid.closest_point_id
  group by day06.id, day06.x, day06.y
),
excluded_points as (
  select day06.id
  from
  day06
  where id in (
    select closest_point_id
    from day06_grid as grid
    where
      grid.x = (select max(x) from day06_grid)
       or
      grid.x = (select min(x) from day06_grid)
       or
      grid.y = (select max(y) from day06_grid)
       or
      grid.y = (select min(y) from day06_grid)
  )
)
select *
from
  nearest_counts left join excluded_points using (id)
where
excluded_points.id is null
order by
nearest_count desc;
