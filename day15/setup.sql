drop function if exists day15_set_distances;
drop table if exists day15, day15_grid, day15_soldier, day15_distance;

create table day15 (
  id serial not null,
  line text not null
);

\copy day15 (line) from './input.txt';

update day15 set id = id - 1;

create table day15_grid (
  x int not null,
  y int not null,
  value text not null,
  constraint pk_day15_grid primary key (x, y)
);

with source as (
  select id as x, regexp_split_to_table(line, '') as value from day15
)
insert into day15_grid
  (x, y, value)
select
x, row_number() over (partition by x) - 1, value
from
source;

create table day15_soldier (
  id serial not null primary key,
  army text not null check (army in ('elf', 'goblin')),
  x int not null,
  y int not null,
  hit_points int not null default 200,
  constraint fk_day15_soldier_x_y foreign key (x, y) references day15_grid (x, y)
);

insert into day15_soldier (army, x, y)
select
    case when value = 'E' then 'elf' else 'goblin' end,
    x,
    y
from
day15_grid
where
value in ('E', 'G');

update day15_grid set value = '.' where value in ('E', 'G');

delete from day15_grid where value = '#';

alter table day15_grid add constraint ck_day15_grid__value check (value  = '.');

create table day15_distance (
  from_x int not null,
  from_y int not null,
  to_x int not null,
  to_y int not null,
  distance int not null,
  constraint pk_day15_distance primary key (from_x, from_y, to_x, to_y),
  constraint fk_day15_distance__from_x_from_y foreign key (from_x, from_y) references day15_grid (x, y),
  constraint fk_day15_distance__to_x_to_y foreign key (to_x, to_y) references day15_grid (x, y)
);

insert into day15_distance
(from_x, from_y, to_x, to_y, distance)
select
from_grid.x, from_grid.y, to_grid.x, to_grid.y, 0
from
day15_grid as from_grid cross join day15_grid as to_grid
where
from_grid.x <> to_grid.x or
from_grid.y <> to_grid.y;

create function day15_set_distances() returns void
language plpgsql
as
$$
    declare
        unmatched_pairs int := 0;
    begin
        -- start with the pairs that are next to each other
        update day15_distance set distance = 1
            where
                (from_x = to_x and abs(from_y - to_y) = 1) or
                (from_y = to_y and abs(from_x - to_x) = 1);

        loop
            select count(*) into unmatched_pairs from day15_distance where distance = 0;
            raise notice ' at %, unmatched pairs left = %', clock_timestamp(), unmatched_pairs;
            exit when unmatched_pairs = 0;

            -- extend what we've found to the next unlinked spot in the path
            with next_pairs as (
                select
                    first_path.from_x,
                    first_path.from_y,
                    second_path.to_x,
                    second_path.to_y,
                    min(first_path.distance + second_path.distance) as new_distance
                from
                    day15_distance as no_path
                        inner join
                        day15_distance as first_path
                            on
                            no_path.distance = 0 and
                            first_path.distance = 1 and
                            no_path.from_x = first_path.from_x and
                            no_path.from_y = first_path.from_y
                            inner join
                            day15_distance as second_path
                                on
                                second_path.distance <> 0 and
                                first_path.to_x = second_path.from_x and
                                first_path.to_y = second_path.from_y and
                                no_path.to_x = second_path.to_x and
                                no_path.to_y = second_path.to_y
                group by
                    first_path.from_x,
                    first_path.from_y,
                    second_path.to_x,
                    second_path.to_y
            )
            update day15_distance
            set distance = next_pairs.new_distance
            from
            next_pairs
            where
            day15_distance.from_x = next_pairs.from_x and
            day15_distance.from_y = next_pairs.from_y and
            day15_distance.to_x = next_pairs.to_x and
            day15_distance.to_y = next_pairs.to_y and
            day15_distance.distance = 0;
        end loop;
    end;
$$
;

-- took 10.5 minutes on my laptop, on battery power
select day15_set_distances();
