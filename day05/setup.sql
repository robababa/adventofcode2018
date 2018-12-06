drop function if exists biggest_reaction;
drop view if exists first_reaction;
drop table if exists day05, day05_chars, day05_work;

create table day05 (full_string text);

\copy day05 from './input.txt';

create table day05_chars (
                           id bigserial not null,
                           ch char(1) not null,
                           previous_id bigint null,
                           previous_ch char(1) null
);

-- break out the characters into individual rows
-- this takes about 24 seconds on my machine
do
  $$
    declare
      my_id bigint := null;
      ch char(1) := ' ';
      previous_ch char(1) := ' ';
    begin
      foreach ch in array (select regexp_split_to_array(full_string, '') from day05 limit 1) loop
        insert into day05_chars (ch, previous_id, previous_ch) values (ch, my_id, previous_ch) returning id into my_id;
        previous_ch := ch;
      end loop;
    end;
    $$
;

with update_source as (
  select id, ch, lag(id) over (order by id) as previous_id, lag(ch) over (order by id) as previous_ch from day05_chars
)
update day05_chars
set
  previous_id = update_source.previous_id,
  previous_ch = update_source.previous_ch
from update_source
where
    day05_chars.id = update_source.id;

create table day05_work (like day05_chars);

create index day05_work_matches_idx on day05_work (id, ch, previous_id, previous_ch)
  where
        ch != previous_ch and upper(ch) = upper(previous_ch) and lower(ch) = lower(previous_ch);

create index day05_work_previous_id_idx on day05_work (previous_id);

create view first_reaction as
select id, ch, previous_id, previous_ch
from day05_work
where
    ch != previous_ch and upper(ch) = upper(previous_ch) and lower(ch) = lower(previous_ch)
order by id
limit 1;

create or replace function biggest_reaction(input_row day05_work) returns day05_work
  language plpgsql
  stable
as
$$
declare
  possible_larger_reaction day05_work;
begin
  select
    id, ch, previous_id, previous_ch into possible_larger_reaction
  from
    (select id, ch from day05_work where id > input_row.id order by id limit 1) as later
      cross join
      (select id as previous_id, ch as previous_ch from day05_work where id < input_row.previous_id order by id desc limit 1) as earlier
  limit 1;

  return input_row;

  if (
      possible_larger_reaction.id is not null and
      possible_larger_reaction.previous_id is not null and
      possible_larger_reaction.ch != possible_larger_reaction.previous_ch and
      upper(possible_larger_reaction.ch) = upper(possible_larger_reaction.previous_ch)
    )
  then
    return biggest_reaction(possible_larger_reaction);
  else
    return input_row;
  end if;
end;
$$
;
