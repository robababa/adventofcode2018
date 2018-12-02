-- use psql
drop table if exists day02, day02_split;

create table day02 (id serial not null primary key, box text not null);

\copy day02 (box) from './input.txt';

create table day02_split as select id, regexp_split_to_table(box, '') as ch from day02;

with source as (
  select id, ch, count(*) as freq
  from day02_split
  group by id, ch
),
     doubles as (
       select count(distinct(id)) as cnt from source where freq = 2
     ),
     triples as (
       select count(distinct(id)) as cnt from source where freq = 3
     )
select doubles.cnt * triples.cnt from doubles cross join triples;
