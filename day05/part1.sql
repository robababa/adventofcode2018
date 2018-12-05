-- use psql
drop view if exists first_reaction;
drop table if exists day05, day05_chars;

create table day05 (full_string text);

\copy day05 from './input.txt';

create table day05_chars (id serial not null, ch char(1) not null, previous_ch char(1) not null);

-- break out the characters into individual rows
-- this takes about 24 seconds on my machine
do
$$
  declare
    ch char(1) := ' ';
    previous_ch char(1) := ' ';
  begin
    foreach ch in array (select regexp_split_to_array(full_string, '') from day05 limit 1) loop
      insert into day05_chars (ch, previous_ch) values (ch, previous_ch);
      previous_ch := ch;
    end loop;
  end;
$$
;

with update_source as (
  select id, ch, coalesce(lag(ch) over (order by id), ' ') as previous_ch from day05_chars
)
update day05_chars
set previous_ch = update_source.previous_ch
from update_source
where
day05_chars.id = update_source.id;

create index day05_chars_matches_idx on day05_chars (id, ch, previous_ch);

-- break out the characters into individual rows
-- do
-- $$
--   declare
--     my_string_length int := 0;
--     my_string text := '';
--   begin
--     my_string_length := (select length(full_string) from day05);
--     my_string := (select full_string from day05);
--   for i in 1..length(my_string) loop
--     insert into day05_chars (ch, previous_ch) values (substr(my_string, i, 1)::char(1), ' '::char(1));
--   end loop;
--   end;
-- $$
-- ;

-- create view first_reaction as
-- with possible_reactions as (
--   select
--    id,
--    ch,
--    lag(id) over (order by id) as previous_id,
--    lag(ch) over (order by id) as previous_ch
--   from day05_chars
--   order by id
-- )
-- select
-- id,
-- previous_id
-- from possible_reactions
-- where
-- upper(ch) = upper(previous_ch) and
-- lower(ch) = lower(previous_ch) and
-- ch != previous_ch
-- order by id
-- limit 1;
--
-- do
-- $$
--   declare
--     affected_rows int := -1;
-- begin
--     while (affected_rows != 0) loop
--       delete from day05_chars
--       using first_reaction
--       where
--       day05_chars.id = first_reaction.id or day05_chars.id = first_reaction.previous_id;
--       get diagnostics affected_rows := ROW_COUNT;
--     end loop;
--   end;
-- $$
-- ;
--
-- select count(*) as part1_answer from day05_chars;
