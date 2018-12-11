with recursive fuel_cell(x, y, size, value)
as
  (
    select x, y, 1 as size, value from day11
    union all
    (
      select
        fuel_cell.x - 1                         as x,
        fuel_cell.y - 1                         as y,
        fuel_cell.size + 1                      as size,
        fuel_cell.value + sum(day11.value) as value
      from
        fuel_cell,
        day11
      where
        -- the fuel cell isn't already hitting the boundary
        fuel_cell.x > 1
        and
        fuel_cell.y > 1
        and
        -- we add coordinates directly left and above the current cell
        (
            (day11.x = fuel_cell.x and day11.y = fuel_cell.y - 1) or
            (day11.x = fuel_cell.x - 1 and day11.y = fuel_cell.y) or
            (day11.x = fuel_cell.x - 1 and day11.y = fuel_cell.y - 1)
          )
      group by
        fuel_cell.x - 1,
        fuel_cell.y - 1,
        fuel_cell.size + 1,
        fuel_cell.value
    )
  )
select
x, y, size, value
from
fuel_cell
order by value desc
limit 5;
