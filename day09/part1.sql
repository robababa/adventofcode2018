drop function if exists day09_regular_move, day09_one_backward, day09_pick_up_and_advance;
drop table if exists day09_marbles, day09_score;

-- sample input: 10 players, last marble is worth 1618 points, high score is 8317
-- puzzle input: 448 players; last marble is worth 71628 points

-- "forward" = clockwise, "backward" = counterclockwise

create table day09_marbles (
  id serial primary key,
  forward int references day09_marbles(id),
  backward int references day09_marbles(id),
  constraint uk_marbles_forward unique (forward) deferrable initially deferred,
  constraint uk_marbles_backward unique (backward) deferrable initially deferred
);

-- put the initial marble in before the game starts
insert into day09_marbles values (0, 0, 0);

-- prime the list juuust a little bit more by playing the first move for the first elf
begin transaction;
insert into day09_marbles (forward, backward) values (0, 0);
update day09_marbles set (forward, backward) = (1, 1) where id = 0;
commit;

-- the move, which returns the new position after inserting the marble
create function day09_regular_move(current_position int) returns int
language sql
as
  $$
    with old_forward_neighbor as (
      select current_forward_neighbor.*
      from day09_marbles as current
        inner join day09_marbles as current_forward_neighbor on current.forward = current_forward_neighbor.id
      where
        current.id = current_position
    ),
    inserted_marble as (
      insert into day09_marbles (forward, backward)
        select forward, id from old_forward_neighbor returning id, forward, backward
    ),
    updated_forward_neighbor as (
      update day09_marbles
      set backward = inserted_marble.id
      from inserted_marble
      where
      day09_marbles.id = inserted_marble.forward
    ),
    updated_backward_neighbor as (
      update day09_marbles
        set forward = inserted_marble.id
        from inserted_marble
        where
        day09_marbles.id = inserted_marble.backward
    )
    select id from inserted_marble;
  $$
;

create function day09_one_backward(current_position int) returns int
language sql
as
  $$
    select backward from day09_marbles where id = current_position;
  $$
;

create function day09_pick_up_and_advance(current_position int) returns int
language sql
as
  $$
    with current_marble as (
      select * from day09_marbles where id = current_position
    ),
    update_backward_neighbor as (
      update day09_marbles as self
      set forward = current_marble.forward
      from current_marble
      where self.id = current_marble.backward
    ),
    update_forward_neighbor as (
      update day09_marbles as self
      set backward = current_marble.backward
      from current_marble
      where self.id = current_marble.forward
      returning self.id
    ),
    delete_current_marble as (
      delete from day09_marbles
      where id = current_position
    )
    select id from update_forward_neighbor;
  $$
;

create table day09_score (
  id serial not null primary key,
  elf int not null,
  score int not null
);

begin transaction;

do
language plpgsql
  $$
    declare
      elves int := 448;
      marbles int := 71628 * 100;
      current_elf int := 1; -- start with elf 0, who already played the first marble
      current_position int := 1;
    begin
      for i in 2..marbles loop
        -- raise notice 'elf % using marble %', current_elf, i;
        if i % 23 <> 0
          then
            -- raise notice '-- regular step elf % using marble %', current_elf, i;
            current_position := day09_regular_move(current_position);
            current_elf := (current_elf + 1) % elves;
            continue;
        end if;

        -- raise notice '-- IRREGULAR step elf % using marble %', current_elf, i;
        -- if we get to this point, we have a multiple-of-23 marble
        -- current elf pockets the multiple-of-23 marble
        insert into day09_score (elf, score) values (current_elf, i);
        -- current elf moves to the marble 7 spots counter-clockwise from current_position
        for j in 1..7 loop
          current_position := day09_one_backward(current_position);
        end loop;
        -- current elf scores the marble in the current position
        insert into day09_score (elf, score) values (current_elf, current_position);
        -- current elf picks up the marble in current position and advances to the next position
        current_position := day09_pick_up_and_advance(current_position);
        -- kind of dumb, but we insert and then delete a row in th marble table to use up
        -- the sequence number for the multiple-of-23 marble
        insert into day09_marbles (forward, backward) values (i, i);
        delete from day09_marbles where id = i;
        -- and finally gives up his turn to the next elf
        current_elf := (current_elf + 1) % elves;
      end loop;
    end;
  $$
;

commit;

select elf, sum(score) from day09_score group by elf order by sum(score) desc limit 5;

/*
 -- diagnostic query
with recursive marble(id, forward, backward, n) as
  (
    select id, forward, backward, 0 as n
    from day09_marbles
    where id = 0
    union all
    select day09_marbles.id, day09_marbles.forward, day09_marbles.backward, marble.n + 1 as n
    from day09_marbles
           inner join marble on day09_marbles.id = marble.forward
    where
      day09_marbles.id <> 0
  )
select * from marble;
*/
