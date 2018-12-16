drop function if exists day14_make_recipes;
drop table if exists day14;

create table day14 (
  id serial not null primary key,
  score int not null
);

insert into day14 (score) values (3), (7);

\set need_made 920831

create function day14_make_recipes(need_made int) returns void
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
        needed int := need_made + 10;
    begin
        loop
            exit when made >= needed;
            score_total := elf1_score + elf2_score;
            -- make new recipes and store their scores
            if (score_total <= 9)
               then
                    -- raise notice 'inserting recipe with score %', score_total;
                    insert into day14 (score) values (score_total);
                    made := made + 1;
            else
                    -- raise notice 'inserting TWO recipes with scores %, %', score_total/10, score_total%10;
                    insert into day14 (score) values (score_total/10), (score_total%10);
                    made := made + 2;
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
    end;
$$
;

select day14_make_recipes(:need_made);

with source as (
  select score::text as text_score
  from day14
  where id between :need_made + 1 and :need_made + 10
  order by id
)
select string_agg(text_score, '') as part1_answer
from source;
