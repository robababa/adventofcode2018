drop table if exists day16, day16_result, day16_operation_code, day16_match;

create table day16 (
    id serial not null primary key,
    line text
);

create table day16_result (
    id serial not null primary key,
    input_id int not null references day16 (id),
    opcode int not null,
    input_a int not null,
    input_b int not null,
    output_c int not null,
    before_0 int not null,
    before_1 int not null,
    before_2 int not null,
    before_3 int not null,
    after_0 int not null,
    after_1 int not null,
    after_2 int not null,
    after_3 int not null
);

create table day16_operation_code (
    id serial not null primary key,
    code text not null
);

create table day16_match (
    id serial not null primary key,
    result_id int not null references day16_result (id),
    code_id int not null references day16_operation_code (id)
);

\copy day16 (line) from './input.txt';

with source as (
  select
         id,
         line as after,
         lag(line, 1) over (order by id) as instruction,
         lag(line, 2) over (order by id) as before
  from day16
  ),
  samples as (
      select * from source where after like 'After%'
  ),
  results as (
      select
            id,
            regexp_split_to_array(replace(replace(replace(before, 'Before: [', ''), ',', ''), ']', ''), ' ') as before_array,
            regexp_split_to_array(instruction, ' ') as instruction_array,
            regexp_split_to_array(replace(replace(replace(after, 'After:  [', ''), ',', ''), ']', ''), ' ') as after_array
      from samples
      where before is not null
  )
insert into day16_result (
    input_id,
    opcode, input_a, input_b, output_c,
    before_0, before_1, before_2, before_3,
    after_0, after_1, after_2, after_3
)
select
    id,
    instruction_array[1]::int, instruction_array[2]::int, instruction_array[3]::int, instruction_array[4]::int,
    before_array[1]::int, before_array[2]::int, before_array[3]::int, before_array[4]::int,
    after_array[1]::int, after_array[2]::int, after_array[3]::int, after_array[4]::int
from results;

insert into day16_operation_code (code)
values ('addr'), ('addi'),
       ('mulr'), ('muli'),
       ('banr'), ('bani'),
       ('borr'), ('bori'),
       ('setr'), ('seti'),
       ('gtir'), ('gtri'), ('gtrr'),
       ('eqir'), ('eqri'), ('eqrr');


\i functions.sql
