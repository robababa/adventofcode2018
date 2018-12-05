-- use psql
drop view if exists day04_guard_sleep_times;
drop table if exists day04;

create table day04 (
  id serial not null primary key,
  event_time timestamp not null,
  action text not null,
  guard int null
);

\copy day04 (event_time, action, guard) from program './load.bash' with delimiter ' ' null 'null';

update day04
set guard = (
  select
  guard
  from day04 as day04_inner
  where
  day04_inner.guard is not null and
  day04_inner.event_time < day04.event_time
  order by day04_inner.event_time desc
  limit 1)
where
guard is null;

create view day04_guard_sleep_times
as
with intervals as (
  select
  guard,
  action,
  lag(event_time) over (order by event_time) as beginning_time,
  event_time as ending_time
  from day04
),
guard_sleep_intervals as (
  select
  guard,
  beginning_time,
  ending_time
  from
  intervals
  where
  action = 'wakes'
),
guard_sleep_minutes as (
select
  guard,
  generate_series(beginning_time, ending_time - interval '1 minute', interval '1 minute') as sleep_by_minute
from
  guard_sleep_intervals
)
select
guard,
extract(minute from sleep_by_minute) as sleep_minute
from
guard_sleep_minutes;

with sleepiest_guard as (
  select guard
  from day04_guard_sleep_times
  group by guard
  order by count(*) desc
  limit 1
),
sleepiest_guard_sleepiest_time as (
  select
  sleep_minute
  from
  sleepiest_guard inner join day04_guard_sleep_times
  on sleepiest_guard.guard = day04_guard_sleep_times.guard
  group by sleep_minute
  order by count(*) desc
  limit 1
)
select
  sleepiest_guard.guard,
  sleepiest_guard_sleepiest_time.sleep_minute,
  sleepiest_guard.guard * sleepiest_guard_sleepiest_time.sleep_minute as part1_answer
from sleepiest_guard
cross join sleepiest_guard_sleepiest_time;

-- part 2
select
guard, sleep_minute, guard * sleep_minute as part2_answer
from day04_guard_sleep_times
group by guard, sleep_minute
order by count(*) desc
limit 1;
