-- use psql
drop table if exists day05;
drop function if exists day05_string_reaction, day05_string_maximum_reaction;
drop type if exists day05_type;

create table day05 (full_string text);

\copy day05 from './input.txt';

create or replace function day05_string_reaction(input text) returns text
language plpgsql
immutable
as
$$
  declare
    input_chars text[];
    last_ch text := null;
    ch text := null;
    result text := '';
  begin
    if (input is null or length(input) = 0)
      then
        return null;
    end if;
    input_chars := regexp_split_to_array(input, '');

    foreach ch in array input_chars loop
      -- raise notice 'ch, last_ch, result are %, %, %', ch, last_ch, result;
      if last_ch is null
        then
          last_ch := ch;
          result = ch;
          continue;
      end if;

      if upper(ch) = upper(right(result, 1)) and ch != right(result, 1)
        then
          result := left(result, length(result) - 1);
          last_ch := right(result, 1);
        else
          last_ch := ch;
          result := result || ch;
      end if;

    end loop;
    return result;
  end;
$$
;

with source as (select full_string from day05)
select length(day05_string_reaction(source.full_string)) as part1_answer from source;
