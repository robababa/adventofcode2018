drop table if exists day07_dependency, day07_step;

create table day07_dependency (
  parent_step text not null,
  child_step text not null
);

\copy day07_dependency from program './load.bash' delimiter ' ';

create table day07_step (
step text not null primary key,
level int null
);

insert into day07_step
select distinct step
from
  (
    select child_step as step from day07_dependency
    union
    select parent_step as step from day07_dependency
    order by 1
  )
as source;

do
$$
declare
  current_level int := 1;
  affected int := 0;
begin
  loop
    with ineligible_steps as (
      select
      step
      from day07_step as target
      where
      -- we already did it
      target.level is not null
      or
      -- it depends on another step that we haven't done yet
      exists(
        select 1
        from day07_dependency
          inner join day07_step as parent on day07_dependency.parent_step = parent.step and parent.level is null
        where
        day07_dependency.child_step = target.step
        )

    ),
    eligible_steps as (
      select step from day07_step except select step from ineligible_steps
    ),
    source as (
      select step from eligible_steps order by step limit 1
    )
    update day07_step set level = current_level from source where day07_step.step = source.step;

    get diagnostics affected := row_count;
    raise notice 'level %, rows affected %', current_level, affected;
    exit when affected = 0;
    current_level := current_level + 1;
  end loop;
end;
$$
;

select step, level, string_agg(step, '') over (order by level)
from day07_step
order by level;
