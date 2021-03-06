drop function if exists day12_create_next_generation, day12_compute_next_state, day12_update_next_generation;
drop table if exists day12_initial_state, day12, day12_rules;

create table day12_initial_state (state text);

\copy day12_initial_state (state) from program './load_initial.bash';

create table day12 (
  generation int not null default 0,
  position int not null,
  state text not null check (state in ('#','.'))
);

with
  initial_values as (select regexp_split_to_table(state, '') as state from day12_initial_state),
  initial_state as (select state, (row_number() over ()) - 1 as position from initial_values)
insert into day12 (position, state)
select position, state from initial_state;

create table day12_rules (
  pattern text not null primary key check (length(pattern) = 5 and replace(pattern, '#', '.') = '.....'),
  output text not null check (length(output) = 1 and output in ('#', '.'))
);

\copy day12_rules (pattern, output) from program './load_rules.bash' with delimiter ' ';

create or replace function day12_create_next_generation(next_gen int) returns void
language plpgsql
as
$$
  begin
  -- first, copy the previous generation to this one
  insert into day12 (generation, position, state)
    select generation + 1, position, state from day12 where generation = next_gen - 1;

  -- naive solution for boundary conditions:
  -- add five empty pots at each end to state every generation
  with boundaries as (
    select min(position) as min_pos, max(position) as max_pos from day12 where generation = next_gen
    ),
    left_expansion as (
      select next_gen as generation, generate_series(min_pos - 1, min_pos - 5, -1) as position, '.' as state
      from boundaries
    ),
    right_expansion as (
      select next_gen as generation, generate_series(max_pos + 1, max_pos + 5, 1) as position, '.' as state
      from boundaries
    )
  insert into day12 (generation, position, state)
  select * from left_expansion union all
  select * from right_expansion;
  end;
$$
;

create or replace function day12_compute_next_state(current_neighborhood text) returns text
language sql
as
$$
  select coalesce(max(output), '.') as value from day12_rules where pattern = current_neighborhood;
$$
;

create or replace function day12_update_next_generation(next_gen int) returns void
language plpgsql
as
$$
  begin
    with source as (
      select
        generation,
        position,
        day12_compute_next_state(
            lag(state, 2, '.') over (order by position) ||
            lag(state, 1, '.') over (order by position) ||
            state ||
            lead(state, 1, '.') over (order by position) ||
            lead(state, 2, '.') over (order by position)
          ) as new_state
      from day12
      where generation = next_gen
    )
    update day12
      set state = new_state
    from source
    where
      day12.generation = source.generation and
      day12.position = source.position;
  end;
$$
;

do
language plpgsql
$$
  declare
  begin
    for gen in 1..20 loop
      perform day12_create_next_generation(gen);
      perform day12_update_next_generation(gen);
    end loop;
  end;
$$
;

-- 3832 is too high
select sum(position) from day12 where generation = 20 and state = '#';
