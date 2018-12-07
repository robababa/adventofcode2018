with source as (
  select
    grid.id
  from
    day06
      cross join day06_grid as grid
  group by grid.id
  having
    sum(abs(day06.x - grid.x) + abs(day06.y - grid.y)) <= 10000
)
select count(*) from source;
