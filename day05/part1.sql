truncate table day05_work;

insert into day05_work select * from day05_chars;

do
$$
  declare
    initial_reaction day05_work;
    maximum_reaction day05_work;
    affected_rows int := 0;
begin
   loop
      select day05_work.* into initial_reaction
      from day05_work
      where ch != previous_ch
        and upper(ch) = upper(previous_ch)
      order by id
      limit 1;

      get diagnostics affected_rows := row_count;

      exit when affected_rows = 0;

      select (biggest_reaction(initial_reaction)).* into maximum_reaction;

      -- update the row directly below the reaction, so its previous columns match the row directly above the reaction
      update day05_work
      set
      (previous_id, previous_ch) =
        (select previous_id, previous_ch from day05_work where id = maximum_reaction.previous_id)
      where
      previous_id = maximum_reaction.id;

      -- now delete the rows in the reaction
      delete from day05_work where id between maximum_reaction.previous_id and maximum_reaction.id;

    end loop;
  end;
$$
;

select count(*) as part1_answer from day05_work;
