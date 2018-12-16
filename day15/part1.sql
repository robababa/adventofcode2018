drop function if exists day15_next_soldier, day15_attack, day15_move, day15_battle;

create function day15_next_soldier(min_x int, min_y int) returns day15_soldier%type
language sql
as
  $$
      select *
      from day15_soldier
      where (x = min_x and y > min_y) or (x > min_x)
      order by x, y
      limit 1;
  $$
;

create function day15_attack(soldier day15_soldier%type) returns int
language sql
as
  $$
      -- given this soldier, look for the first soldier he can attack, if there is one
      with adjacent_enemy as (
          select
          enemy.id
          from day15_soldier as enemy
          where
              enemy.army <> soldier.army and
              (
                  (soldier.x = enemy.x and abs(soldier.y - enemy.y) = 1) or
                  (soldier.y = enemy.y and abs(soldier.x - enemy.x) = 1)
              )
          order by x, y
          limit 1
      ),
      attack_him as (
          update day15_soldier
          set hit_points = hit_points - 3
          from adjacent_enemy
          where id = adjacent_enemy.id
      ),
      maybe_delete_him as (
        delete from day15_soldier
        using adjacent_enemy
        where id = adjacent_enemy.id and hit_points <= 3 -- this query WON'T see the current damage
      )
      select count(*)::int as return_value from adjacent_enemy;
  $$
;

create function day15_move(soldier day15_soldier%type) returns void
language sql
as
  $$
  -- given this soldier, look for the first soldier he can attack, if there is one
    with adjacent_empty_space as (
        select
        from day15_grid as grid
            left join day15_soldier as other_soldier
                on grid.x = other_soldier.x and grid.y = other_soldier.y
        where
        (
            (grid.x = soldier.x and abs(grid.y - soldier.y) = 1) or
            (grid.y = soldier.y and abs(grid.x - soldier.x) = 1)
        )
        and other_soldier.x is null
        order by x, y
        limit 1
    ),

         attack_him as (
           update day15_soldier
             set hit_points = hit_points - 3
             from adjacent_enemy
             where id = adjacent_enemy.id
         ),
         maybe_delete_him as (
           delete from day15_soldier
             using adjacent_enemy
             where id = adjacent_enemy.id and hit_points <= 3 -- this query WON'T see the current damage
         )
    select count(*)::int as return_value from adjacent_enemy;
  $$
;

create function day15_battle() returns void
language plpgsql
as
  $$
      declare
          elf_count int := 0;
          goblin_count int := 0;
          soldier day15_soldier%type;
          min_x int := 0;
          min_y int := 0;
      begin
          loop
              soldier := day15_next_soldier(min_x, min_y);
              -- if the soldier can attack, that's all he will do
              if day15_attack(soldier) > 0
                then
                  continue;
              end if;

              -- update the search criteria for the next soldier
              min_x := soldier.x;
              min_y := soldier.y;
          end loop;
      end;
  $$
;
