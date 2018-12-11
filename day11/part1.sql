-- use psql
drop table if exists day11 cascade;

\set puzzle_input 5719

create table day11 (
  x int not null,
  y int not null,
  value int not null default 0,
  constraint pk_day11 primary key (x, y)
);

create index day11__y_idx on day11(y);

with
     x as (select generate_series(1, 300, 1) as x),
     y as (select generate_series(1, 300, 1) as y)
insert into day11 (x, y, value)
select
x.x,
y.y,
((x + 10) * y + :puzzle_input) * (x + 10) / 100 % 10 - 5
from
x cross join y;

select
       top_left.x as x_top_left, top_left.y as y_top_left, sum(day11.value) as answer
from
day11 as top_left
inner join
day11 on (day11.x = top_left.x or day11.x = top_left.x + 1 or day11.x = top_left.x + 2) and
         (day11.y = top_left.y or day11.y = top_left.y + 1 or day11.y = top_left.y + 2)
where
top_left.x <= 297 and top_left.y <= 297
group by
top_left.x, top_left.y
order by sum(day11.value) desc
limit 1;

