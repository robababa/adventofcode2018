drop table if exists day03, day03_squares;

create table day03 (
  id bigint not null,
  from_left int not null,
  from_top int not null,
  width int not null,
  height int not null
);

\copy day03 from program 'sed ''s%#%%g; s#@ ##g; s#,# #g; s#:##g; s#x# #g'' ./input.txt' with delimiter ' ';

create table day03_squares (
  claim_id bigint not null,
  from_left int not null,
  from_top int not null
);

insert into day03_squares
select
  id,
  generate_series(from_left, from_left + width - 1, 1) as from_left,
  generate_series(from_top, from_top + height - 1, 1) as from_top
from
day03;


with
  source as (select id, from_left, from_top, width, height from day03),
  column_positions as (select id, generate_series(from_left, from_left + width - 1, 1) as from_left from source),
  row_positions as (select id, generate_series(from_top, from_top + height - 1, 1) as from_top from source),
points as (
  select
    source.id,
    column_positions.from_left,
    row_positions.from_top
  from
    source
      inner join column_positions on source.id = column_positions.id
      inner join row_positions on source.id = row_positions.id
)
insert into day03_squares select * from points;

with duplicates as (select from_left, from_top from day03_squares group by from_left, from_top having count(*) > 1)
select count(*) from duplicates;
