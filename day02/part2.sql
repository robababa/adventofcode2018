drop table if exists day02_part2, day02_part2_diffs;

create table day02_part2 (
  newid serial not null,
  id bigint not null,
  ch text not null,
  position int null
);

insert into day02_part2 (id, ch)
select id, regexp_split_to_table(box, '') as ch from day02;

with positions as
(
  select newid, id, ch, rank() over (partition by id order by newid) as position
  from day02_part2
)
update day02_part2
set position = positions.position
from positions
where
day02_part2.newid = positions.newid;

create table day02_part2_diffs (
  smaller_id bigint not null,
  bigger_id bigint not null,
  differences int not null default 0
);

insert into day02_part2_diffs
select smaller.id as smaller_id, bigger.id as bigger_id
from day02 as smaller cross join day02 as bigger
where smaller.id < bigger.id;

create or replace function f_day02_part2() returns void language plpgsql
as
$$
declare
  boxlength int := 0;
begin
  select length(box) into boxlength from day02 limit 1;
  for i in 1..boxlength loop
    update day02_part2_diffs
    set differences = differences + 1
    from
         day02_part2 as smaller, day02_part2 as bigger
    where
          smaller.position = i
    and
          smaller.id = day02_part2_diffs.smaller_id
    and
          bigger.position = i
    and
          bigger.id = day02_part2_diffs.bigger_id
    and
          smaller.ch <> bigger.ch;
    delete from day02_part2_diffs where differences > 1;
  end loop;
end;
$$;

select f_day02_part2();

-- this shows us the two correct boxes, but we have to inspect them manually to see their shared letters
select
smaller.box as smaller_box, bigger.box as bigger_box
from
day02 as smaller
inner join day02_part2_diffs as diffs on smaller.id = diffs.smaller_id
inner join day02 as bigger on diffs.bigger_id = bigger.id;
