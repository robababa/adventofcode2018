-- use psql
drop table if exists day05;
drop function if exists day05_string_reaction, day05_string_maximum_reaction;
drop type if exists day05_type;

create table day05 (full_string text);

\copy day05 from './input.txt';

create type day05_type as (
  polymer text,
  start_position int
);

create or replace function day05_string_reaction(input day05_type) returns day05_type
language plpgsql
immutable
as
$$
  declare
    old_ch text := null;
    new_ch text := null;
  begin
    for i in (input.start_position)..((input.polymer).length) loop
      new_ch := substr(input.polymer, i, 1);
      -- raise notice 'comparing % and %', old_ch, new_ch;
      if (upper(new_ch) = upper(old_ch) and new_ch != old_ch)
        then
          -- clip the i and (i-1) characters from the string
          -- new starting point will be character i - 2
          return (substr(input.polymer, 1, i - 2) || substr(input.polymer, i + 1), i - 2)::day05_type;
        else
          old_ch := new_ch;
      end if;
    end loop;
    return input;
  end;
$$
;

create or replace function day05_string_maximum_reaction(input text) returns text
language plpgsql
immutable
as
$$
  declare
    old_input day05_type;
    new_input day05_type;
  begin
    select ((input, 1)::day05_type).* into old_input;
    select (('', 1)::day05_type).* into new_input;
    loop
      -- raise notice 'checking string %', old_input;
      select (day05_string_reaction(old_input)).* into new_input;
      exit when new_input.polymer = old_input.polymer or new_input.polymer = '' or new_input.polymer is null;
      old_input := new_input;
    end loop;
    return new_input.polymer;
  end;
$$
;

with source as (select full_string from day05)
select length(day05_string_maximum_reaction(source.full_string)) as answer from source;
