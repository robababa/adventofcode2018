-- use psql
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

with intervals as (
  select
  guard,
  action,
  lag(event_time) over (order by event_time) as beginning_time,
  event_time as ending_time,
  (event_time - interval '1 minute') - lag(event_time) over (order by event_time) as time_interval
  from day04
),
sleepiest_guard as (
  select
  guard, sum(time_interval) as sleep_time
  from
  intervals
  where
  action = 'wakes'
  group by guard
  order by sleep_time desc
  limit 1
),
sleepiest_guard_sleep_intervals as (
  select
  sleepiest_guard.guard,
  intervals.beginning_time,
  intervals.ending_time
  from
  sleepiest_guard
    inner join intervals
      on sleepiest_guard.guard = intervals.guard
  where
  intervals.action = 'wakes'
),
sleepiest_guard_sleep_times as (
  select
  generate_series(beginning_time, ending_time - interval '1 minute', interval '1 minute')
    as sleep_time
  from sleepiest_guard_sleep_intervals
),
best_sleep_time as (
  select
  extract(minute from sleep_time) as sleep_minute
  from sleepiest_guard_sleep_times
  group by extract(minute from sleep_time)
  order by count(*) desc limit 1
)
--select sleep_time, count(*) from sleepiest_guard_sleep_times group by sleep_time order by sleep_time;
select
  sleepiest_guard.guard,
  best_sleep_time.sleep_minute,
  sleepiest_guard.guard * best_sleep_time.sleep_minute as product
from sleepiest_guard
cross join best_sleep_time;

-- 35383 is too low - 863 and 41
