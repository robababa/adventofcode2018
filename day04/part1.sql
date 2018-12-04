-- use psql
drop table if exists day04;

create table day04 (
  id serial not null primary key,
  event_time timestamp not null,
  action text not null,
  guard int null
);

\copy day04 (event_time, action, guard) from program './load.bash' with delimiter ' ' null 'null';
