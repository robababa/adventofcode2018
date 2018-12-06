drop function if exists day05_part2;

create function day05_part2(input text) returns int
language plpgsql
as
$$
  declare
    char_to_remove text := ' ';
    shortest_length int;
    shorter_input text := '';
    output text;
    result text := '';
  begin
    for i in 0..25 loop
      char_to_remove := chr(ascii('a') + i);
      raise notice 'removing %', char_to_remove;
      shorter_input := regexp_replace(
        input,
        '(' || char_to_remove || '|' || upper(char_to_remove) || ')', '', 'g'
        );
      output := day05_string_maximum_reaction(shorter_input);
      raise notice 'output length is %', length(output);
      shortest_length := least(coalesce(shortest_length, length(output)), length(output));
      raise notice 'shortest length is %', shortest_length;
    end loop;
    return shortest_length;
  end;
$$
;

with source as (select full_string from day05) select day05_part2(full_string) as answer from source;
