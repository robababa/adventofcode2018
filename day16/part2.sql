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
