drop function if exists open_workers, open_jobs;
drop table if exists day07_dependency, day07_job, day07_worker, day07_assignment;


create table day07_dependency (
  parent_step text not null,
  child_step text not null
);

\copy day07_dependency from program './load.bash' delimiter ' ';

create table day07_job (
  job text not null primary key,
  duration int not null default 0
);

insert into day07_job
select distinct job
from
  (
    select child_step as job from day07_dependency
    union
    select parent_step as job from day07_dependency
    order by 1
  )
    as source;

-- job A takes 61 seconds, B takes 62 seconds, etc.
update day07_job set duration = ascii(job) - ascii('A') + 61;

create table day07_worker (
  worker text not null primary key
);

insert into day07_worker (worker)
values
('Elf 1 (me)'),
('Elf 2'),
('Elf 3'),
('Elf 4'),
('Elf 5');

create table day07_assignment (
  work_second int not null,
  job text not null references day07_job (job),
  worker text not null references day07_worker (worker)
);

create function open_workers(work_second_in int) returns setof day07_worker
language sql
as
  $$
  select
  day07_worker.*
  from day07_worker
    left join day07_assignment
      on day07_worker.worker = day07_assignment.worker and day07_assignment.work_second = work_second_in
  where day07_assignment.worker is null;
  $$
;


create function open_jobs(work_second_in int) returns setof day07_job
language sql
as
  $$
  select
  day07_job.*
  from day07_job
    where
          -- this job wasn't already assigned
          not exists(select 1 from day07_assignment where job = day07_job.job)
          and
          -- this job has no un-started or unfinished dependencies
          not exists(
              select 1
              from day07_dependency
                     inner join day07_job as parent
                                on day07_job.job = day07_dependency.child_step and
                                   day07_dependency.parent_step = parent.job
              where
                 -- parent not started at all
                parent.job not in (select job from day07_assignment)
                or
                -- parent not finished yet
                parent.job in (select job from day07_assignment where work_second = work_second_in)
          )

  $$
;

do
$$
  declare
    time_second int := 1;
    remaining_jobs int := 0;
    active_jobs int := 0;
    rows_inserted int := 0;
  begin
    loop
      select count(*) into remaining_jobs from open_jobs(time_second);
      select count(*) into active_jobs from day07_assignment where work_second = time_second;
      exit when remaining_jobs + active_jobs = 0;

      with matches as (
        select
          available_jobs.job,
          available_jobs.duration,
          available_workers.worker
        from
          (select job, duration, rank() over (order by job) as priority from open_jobs(time_second)) as available_jobs
            inner join
            (select worker, rank() over (order by worker) as priority from open_workers(time_second)) as available_workers
            on
              available_jobs.priority = available_workers.priority
      )
      insert into day07_assignment (work_second, job, worker)
      select generate_series(time_second, time_second + matches.duration - 1, 1), job, worker
      from matches;

      get diagnostics rows_inserted = row_count;
      raise notice 'time = % seconds, jobs assigned = %', time_second, rows_inserted;

      time_second := time_second + 1;
    end loop;
  end;
$$
;

select work_second, worker, job from day07_assignment order by work_second, worker \crosstabview
