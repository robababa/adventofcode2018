-- use psql
drop table if exists day01_part2;

create table day01_part2 (id serial not null, total_change int not null unique);

create or replace function f_day01_part2() returns void language plpgsql as
$$
declare
  current_value int := 0;
  day01_row day01%rowtype;
begin
while true loop
  for day01_row in (select * from day01 order by id) loop
  current_value := current_value + day01_row.change;
  insert into day01_part2 (total_change) values (current_value);
  end loop;
end loop;
end;
$$
;

select f_day01_part2();

-- output
-- advent=# \i part2.sql
-- DROP TABLE
--   CREATE TABLE
-- CREATE FUNCTION
--   psql:part2.sql:32: ERROR:  duplicate key value violates unique constraint "day01_part2_total_change_key"
--   DETAIL:  Key (total_change)=(464) already exists.
--   CONTEXT:  SQL statement "insert into day01_part2 (total_change) values (current_value)"
--   PL/pgSQL function f_day01_part2() line 9 at SQL statement

drop table day01_part2;

-- go ahead and drop the part 1 table
drop table day01;
