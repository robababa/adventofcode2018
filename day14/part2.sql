drop function if exists day14_make_recipes_part2;
drop table if exists day14, day14_search;

create table day14 (
                     id serial not null primary key,
                     score int not null
);

insert into day14 (score) values (3), (7);

create table day14_search (
  search_string text
);

insert into day14_search values ('920831');

create function day14_make_recipes_part2(search_for int, search_for_length int) returns int
  language plpgsql
as
$$
declare
  elf1_position int := 1;
  elf1_score int := 3;
  elf2_position int := 2;
  elf2_score int := 7;
  score_total int := 0;
  made int := 2;
  rounds int := 0;
  search_value int := 37;
  upper_limit int := power(10, search_for_length)::int;
  score_total_div_10 int := 0;
  score_total_mod_10 int := 0;
begin
  loop
    rounds := rounds + 1;
    if rounds % 100000 = 0
      then
        raise notice 'round % at time %', rounds, clock_timestamp();
    end if;

    score_total := elf1_score + elf2_score;
    -- make new recipes and store their scores
    if (score_total <= 9)
    then
      -- raise notice 'inserting recipe with score %', score_total;
      insert into day14 (score) values (score_total);
      made := made + 1;
      search_value := search_value * 10 % upper_limit + score_total;
      exit when search_value = search_for;
    else
      score_total_div_10 := score_total / 10;
      score_total_mod_10 := score_total % 10;
      -- raise notice 'inserting TWO recipes with scores %, %', score_total/10, score_total%10;
      insert into day14 (score) values (score_total_div_10), (score_total_mod_10);

      made := made + 1;
      search_value := search_value * 10 % upper_limit + score_total_div_10;
      exit when search_value = search_for;

      made := made + 1;
      search_value := search_value * 10 % upper_limit + score_total_mod_10;
      exit when search_value = search_for;
    end if;

    -- move the elves to their new recipes
    select id, score into elf1_position, elf1_score
    from day14
    where id = (elf1_position - 1 + elf1_score + 1) % made + 1;
    -- raise notice 'elf1 in position % with score %', elf1_position, elf1_score;

    select id, score into elf2_position, elf2_score
    from day14
    where id = (elf2_position - 1 + elf2_score + 1) % made + 1;
    -- raise notice 'elf2 in position % with score %', elf2_position, elf2_score;

  end loop;
  return made - search_for_length;
end;
$$
;

-- answer is 20236441
select day14_make_recipes_part2(search_string::int, length(search_string))
  as part2_answer
from day14_search;
