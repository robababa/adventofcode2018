-- use psql
drop view if exists first_reaction;
drop table if exists day05, day05_chars;

create table day05 (full_string text);

\copy day05 from './input.txt';

create table day05_chars (
  id serial not null,
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

create index day05_chars_matches_idx on day05_chars (id, ch, previous_id, previous_ch)
where
ch != previous_ch and upper(ch) = upper(previous_ch) and lower(ch) = lower(previous_ch);

create index day05_chars_previous_id_idx on day05_chars (previous_id);

create view first_reaction as
select id, previous_id, ch, previous_ch
from day05_chars
where
ch != previous_ch and upper(ch) = upper(previous_ch) and lower(ch) = lower(previous_ch)
order by id
limit 1;

do
$$
  declare
    reaction first_reaction%rowtype;
    affected_rows int := 0;
begin
    loop
      select * into reaction from first_reaction;
      get diagnostics affected_rows := ROW_COUNT;
      exit when affected_rows = 0;

      -- update the row directly below the reaction, so its previous columns match the row directly above the reaction
      update day05_chars
      set
      (previous_id, previous_ch) =
        (select previous_id, previous_ch from day05_chars where id = reaction.previous_id)
      where
      previous_id = reaction.id;

      -- now delete the rows in the reaction
      delete from day05_chars where id = reaction.id or id = reaction.previous_id;

    end loop;
  end;
$$
;

select count(*) as part1_answer from day05_chars;
