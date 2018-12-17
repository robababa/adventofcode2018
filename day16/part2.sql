drop table if exists day16_part2_instruction;
drop function if exists day16_assign_codes;
alter table day16_operation_code drop column opcode;

alter table day16_operation_code add column opcode int unique check (opcode between 0 and 15);

create function day16_assign_codes() returns setof int
language sql
as
  $$
    with possible_matches as (
      select match.code_id, result.opcode
      from
        day16_result as result
          inner join day16_match as match
                     on result.id = match.result_id
          left join day16_operation_code as already_taken_code
                    on result.opcode = already_taken_code.opcode and already_taken_code.id is not null
          left join day16_operation_code as already_taken_id
                    on match.code_id = already_taken_id.id and already_taken_id.opcode is not null
      where
        already_taken_code is null and
        already_taken_id is null
      group by match.code_id, result.opcode
      order by match.code_id
    ),
    mandatory_code_id_matches as (
      select code_id, max(opcode) as opcode
      from possible_matches
      group by code_id
      having min(opcode) = max(opcode)
    ),
    mandatory_opcode_matches as (
      select max(code_id) as code_id, opcode
      from possible_matches
      group by opcode
      having min(code_id) = max(code_id)
    ),
    mandatory_matches as (
      select code_id, opcode from mandatory_code_id_matches
      union
      select code_id, opcode from mandatory_opcode_matches
    )
    update day16_operation_code
      set opcode = mandatory_matches.opcode
      from mandatory_matches
      where day16_operation_code.id = mandatory_matches.code_id
      returning id
  $$
;

do
language plpgsql
$$
  declare
    affected bigint := 0;
  begin
    loop
      select count(*) into affected from day16_assign_codes();
      exit when affected = 0;
    end loop;
  end;
$$
;

create table day16_part2_instruction (
  id int not null primary key,
  opcode_id int not null,
  input_a int not null,
  input_b int not null,
  output_c int not null
);

with last_after as (
    select max(id) as last_after_id from day16 where line like 'After%'
),
text_instructions as (
    select
        id,
        line
    from day16 cross join last_after
    where
        id > last_after_id and
        length(line) > 0
),
split_insructions as (
    select
        id,
        regexp_split_to_array(line, ' ') as instruction_array
    from text_instructions
)
insert into day16_part2_instruction (id, opcode_id, input_a, input_b, output_c)
select
  id,
  (instruction_array[1])::int,
  (instruction_array[2])::int,
  (instruction_array[3])::int,
  (instruction_array[4])::int
from
split_insructions;

-- 3 is wrong
do
language plpgsql
$$
  declare
    register_values int[] := ARRAY[0, 0, 0, 0];
    command record;
  begin
    for command in (
        select code.code, inst.input_a, inst.input_b, inst.output_c
        from day16_part2_instruction as inst
            inner join day16_operation_code as code
            on inst.opcode_id = code.opcode
        order by inst.id
    ) loop
        -- raise notice 'register values is %', register_values;
        -- raise notice 'operation is % % % %', command.code, command.input_a, command.input_b, command.output_c;
        --operation text, input_a int, input_b int, output_c int, r0 int, r1 int, r2 int, r3 int
        register_values := day16_operation(
            command.code, command.input_a, command.input_b, command.output_c,
            register_values[1], register_values[2], register_values[3], register_values[4]
        );
    end loop;
    raise notice 'final register values are %', register_values;
  end;
$$
;
