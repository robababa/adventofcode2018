drop function if exists
  day16_two_registers, day16_register_and_value,
  day16_addr, day16_addi, day16_mulr, day16_muli, day16_banr, day16_bani, day16_borr, day16_bori,
  day16_setr, day16_seti, day16_gtir, day16_gtri, day16_gtrr, day16_eqir, day16_eqri, day16_eqrr,
  day16_operation;
drop table if exists day16_two_operands;

create table day16_two_operands (
  first_value int,
  second_value int
);

create function day16_two_registers(input_a int, input_b int, r0 int, r1 int, r2 int, r3 int)
returns day16_two_operands
language sql
as
  $$
    select
           case input_a when 0 then r0 when 1 then r1 when 2 then r2 when 3 then r3 else null::int end as first_value,
           case input_b when 0 then r0 when 1 then r1 when 2 then r2 when 3 then r3 else null::int end as second_value;
  $$
;

create function day16_register_and_value(input_a int, input_b int, r0 int, r1 int, r2 int, r3 int)
  returns day16_two_operands
  language sql
as
$$
select
  case input_a when 0 then r0 when 1 then r1 when 2 then r2 when 3 then r3 else null::int end as first_value,
  input_b as second_value;
$$
;

create function day16_addr(input_a int, input_b int, output_c int, r0 int, r1 int, r2 int, r3 int) returns int[]
language sql
as
  $$
      with inputs as (
          select (day16_two_registers(input_a, input_b, r0, r1, r2, r3)).*
      )
      select ARRAY[
        case when output_c = 0 then first_value + second_value else r0 end,
        case when output_c = 1 then first_value + second_value else r1 end,
        case when output_c = 2 then first_value + second_value else r2 end,
        case when output_c = 3 then first_value + second_value else r3 end
      ]
      from inputs;
  $$
;

create function day16_addi(input_a int, input_b int, output_c int, r0 int, r1 int, r2 int, r3 int) returns int[]
  language sql
as
  $$
      with inputs as (
        select (day16_register_and_value(input_a, input_b, r0, r1, r2, r3)).*
      )
      select ARRAY[
               case when output_c = 0 then first_value + second_value else r0 end,
               case when output_c = 1 then first_value + second_value else r1 end,
               case when output_c = 2 then first_value + second_value else r2 end,
               case when output_c = 3 then first_value + second_value else r3 end
               ]
      from inputs;
      $$
;

create function day16_mulr(input_a int, input_b int, output_c int, r0 int, r1 int, r2 int, r3 int) returns int[]
  language sql
as
$$
with inputs as (
  select (day16_two_registers(input_a, input_b, r0, r1, r2, r3)).*
)
select ARRAY[
         case when output_c = 0 then first_value * second_value else r0 end,
         case when output_c = 1 then first_value * second_value else r1 end,
         case when output_c = 2 then first_value * second_value else r2 end,
         case when output_c = 3 then first_value * second_value else r3 end
         ]
from inputs;
$$
;

create function day16_muli(input_a int, input_b int, output_c int, r0 int, r1 int, r2 int, r3 int) returns int[]
  language sql
as
$$
with inputs as (
  select (day16_register_and_value(input_a, input_b, r0, r1, r2, r3)).*
)
select ARRAY[
         case when output_c = 0 then first_value * second_value else r0 end,
         case when output_c = 1 then first_value * second_value else r1 end,
         case when output_c = 2 then first_value * second_value else r2 end,
         case when output_c = 3 then first_value * second_value else r3 end
         ]
from inputs;
$$
;

create function day16_banr(input_a int, input_b int, output_c int, r0 int, r1 int, r2 int, r3 int) returns int[]
  language sql
as
$$
with inputs as (
  select (day16_two_registers(input_a, input_b, r0, r1, r2, r3)).*
)
select ARRAY[
         case when output_c = 0 then (first_value::bit(32) & second_value::bit(32))::int else r0 end,
         case when output_c = 1 then (first_value::bit(32) & second_value::bit(32))::int else r1 end,
         case when output_c = 2 then (first_value::bit(32) & second_value::bit(32))::int else r2 end,
         case when output_c = 3 then (first_value::bit(32) & second_value::bit(32))::int else r3 end
         ]
from inputs;
$$
;

create function day16_bani(input_a int, input_b int, output_c int, r0 int, r1 int, r2 int, r3 int) returns int[]
  language sql
as
$$
with inputs as (
  select (day16_register_and_value(input_a, input_b, r0, r1, r2, r3)).*
)
select ARRAY[
         case when output_c = 0 then (first_value::bit(32) & second_value::bit(32))::int else r0 end,
         case when output_c = 1 then (first_value::bit(32) & second_value::bit(32))::int else r1 end,
         case when output_c = 2 then (first_value::bit(32) & second_value::bit(32))::int else r2 end,
         case when output_c = 3 then (first_value::bit(32) & second_value::bit(32))::int else r3 end
         ]
from inputs;
$$
;

create function day16_borr(input_a int, input_b int, output_c int, r0 int, r1 int, r2 int, r3 int) returns int[]
  language sql
as
$$
with inputs as (
  select (day16_two_registers(input_a, input_b, r0, r1, r2, r3)).*
)
select ARRAY[
         case when output_c = 0 then (first_value::bit(32) | second_value::bit(32))::int else r0 end,
         case when output_c = 1 then (first_value::bit(32) | second_value::bit(32))::int else r1 end,
         case when output_c = 2 then (first_value::bit(32) | second_value::bit(32))::int else r2 end,
         case when output_c = 3 then (first_value::bit(32) | second_value::bit(32))::int else r3 end
         ]
from inputs;
$$
;

create function day16_bori(input_a int, input_b int, output_c int, r0 int, r1 int, r2 int, r3 int) returns int[]
  language sql
as
$$
with inputs as (
  select (day16_register_and_value(input_a, input_b, r0, r1, r2, r3)).*
)
select ARRAY[
         case when output_c = 0 then (first_value::bit(32) | second_value::bit(32))::int else r0 end,
         case when output_c = 1 then (first_value::bit(32) | second_value::bit(32))::int else r1 end,
         case when output_c = 2 then (first_value::bit(32) | second_value::bit(32))::int else r2 end,
         case when output_c = 3 then (first_value::bit(32) | second_value::bit(32))::int else r3 end
         ]
from inputs;
$$
;

create function day16_setr(input_a int, input_b int, output_c int, r0 int, r1 int, r2 int, r3 int) returns int[]
  language sql
as
$$
with inputs as (
  select (day16_register_and_value(input_a, input_b, r0, r1, r2, r3)).*
)
select ARRAY[
         case when output_c = 0 then first_value else r0 end,
         case when output_c = 1 then first_value else r1 end,
         case when output_c = 2 then first_value else r2 end,
         case when output_c = 3 then first_value else r3 end
         ]
from inputs;
$$
;

create function day16_seti(input_a int, input_b int, output_c int, r0 int, r1 int, r2 int, r3 int) returns int[]
  language sql
as
$$
with inputs as (
  select input_a as first_value
)
select ARRAY[
         case when output_c = 0 then first_value else r0 end,
         case when output_c = 1 then first_value else r1 end,
         case when output_c = 2 then first_value else r2 end,
         case when output_c = 3 then first_value else r3 end
         ]
from inputs;
$$
;

create function day16_gtir(input_a int, input_b int, output_c int, r0 int, r1 int, r2 int, r3 int) returns int[]
  language sql
as
$$
with inputs as (
  select (day16_register_and_value(input_b, input_a, r0, r1, r2, r3)).*
)
select ARRAY[
         case when output_c = 0 then (case when second_value > first_value then 1 else 0 end) else r0 end,
         case when output_c = 1 then (case when second_value > first_value then 1 else 0 end) else r1 end,
         case when output_c = 2 then (case when second_value > first_value then 1 else 0 end) else r2 end,
         case when output_c = 3 then (case when second_value > first_value then 1 else 0 end) else r3 end
         ]
from inputs;
$$
;

create function day16_gtri(input_a int, input_b int, output_c int, r0 int, r1 int, r2 int, r3 int) returns int[]
  language sql
as
$$
with inputs as (
  select (day16_register_and_value(input_a, input_b, r0, r1, r2, r3)).*
)
select ARRAY[
         case when output_c = 0 then (case when first_value > second_value then 1 else 0 end) else r0 end,
         case when output_c = 1 then (case when first_value > second_value then 1 else 0 end) else r1 end,
         case when output_c = 2 then (case when first_value > second_value then 1 else 0 end) else r2 end,
         case when output_c = 3 then (case when first_value > second_value then 1 else 0 end) else r3 end
         ]
from inputs;
$$
;

create function day16_gtrr(input_a int, input_b int, output_c int, r0 int, r1 int, r2 int, r3 int) returns int[]
  language sql
as
$$
with inputs as (
  select (day16_two_registers(input_a, input_b, r0, r1, r2, r3)).*
)
select ARRAY[
         case when output_c = 0 then (case when first_value > second_value then 1 else 0 end) else r0 end,
         case when output_c = 1 then (case when first_value > second_value then 1 else 0 end) else r1 end,
         case when output_c = 2 then (case when first_value > second_value then 1 else 0 end) else r2 end,
         case when output_c = 3 then (case when first_value > second_value then 1 else 0 end) else r3 end
         ]
from inputs;
$$
;

create function day16_eqir(input_a int, input_b int, output_c int, r0 int, r1 int, r2 int, r3 int) returns int[]
  language sql
as
$$
with inputs as (
  select (day16_register_and_value(input_b, input_a, r0, r1, r2, r3)).*
)
select ARRAY[
         case when output_c = 0 then (case when second_value = first_value then 1 else 0 end) else r0 end,
         case when output_c = 1 then (case when second_value = first_value then 1 else 0 end) else r1 end,
         case when output_c = 2 then (case when second_value = first_value then 1 else 0 end) else r2 end,
         case when output_c = 3 then (case when second_value = first_value then 1 else 0 end) else r3 end
         ]
from inputs;
$$
;

create function day16_eqri(input_a int, input_b int, output_c int, r0 int, r1 int, r2 int, r3 int) returns int[]
  language sql
as
$$
with inputs as (
  select (day16_register_and_value(input_a, input_b, r0, r1, r2, r3)).*
)
select ARRAY[
         case when output_c = 0 then (case when first_value = second_value then 1 else 0 end) else r0 end,
         case when output_c = 1 then (case when first_value = second_value then 1 else 0 end) else r1 end,
         case when output_c = 2 then (case when first_value = second_value then 1 else 0 end) else r2 end,
         case when output_c = 3 then (case when first_value = second_value then 1 else 0 end) else r3 end
         ]
from inputs;
$$
;

create function day16_eqrr(input_a int, input_b int, output_c int, r0 int, r1 int, r2 int, r3 int) returns int[]
  language sql
as
$$
with inputs as (
  select (day16_two_registers(input_a, input_b, r0, r1, r2, r3)).*
)
select ARRAY[
         case when output_c = 0 then (case when first_value = second_value then 1 else 0 end) else r0 end,
         case when output_c = 1 then (case when first_value = second_value then 1 else 0 end) else r1 end,
         case when output_c = 2 then (case when first_value = second_value then 1 else 0 end) else r2 end,
         case when output_c = 3 then (case when first_value = second_value then 1 else 0 end) else r3 end
         ]
from inputs;
$$
;

create function day16_operation(operation text, input_a int, input_b int, output_c int, r0 int, r1 int, r2 int, r3 int)
returns int[]
language sql
as
$$
select
  case operation
    when 'addr' then day16_addr(input_a, input_b, output_c, r0, r1, r2, r3)
    when 'addi' then day16_addi(input_a, input_b, output_c, r0, r1, r2, r3)
    when 'mulr' then day16_mulr(input_a, input_b, output_c, r0, r1, r2, r3)
    when 'muli' then day16_muli(input_a, input_b, output_c, r0, r1, r2, r3)
    when 'banr' then day16_banr(input_a, input_b, output_c, r0, r1, r2, r3)
    when 'bani' then day16_bani(input_a, input_b, output_c, r0, r1, r2, r3)
    when 'borr' then day16_borr(input_a, input_b, output_c, r0, r1, r2, r3)
    when 'bori' then day16_bori(input_a, input_b, output_c, r0, r1, r2, r3)
    when 'setr' then day16_setr(input_a, input_b, output_c, r0, r1, r2, r3)
    when 'seti' then day16_seti(input_a, input_b, output_c, r0, r1, r2, r3)
    when 'gtir' then day16_gtir(input_a, input_b, output_c, r0, r1, r2, r3)
    when 'gtri' then day16_gtri(input_a, input_b, output_c, r0, r1, r2, r3)
    when 'gtrr' then day16_gtrr(input_a, input_b, output_c, r0, r1, r2, r3)
    when 'eqir' then day16_eqir(input_a, input_b, output_c, r0, r1, r2, r3)
    when 'eqri' then day16_eqri(input_a, input_b, output_c, r0, r1, r2, r3)
    when 'eqrr' then day16_eqrr(input_a, input_b, output_c, r0, r1, r2, r3)
    else ARRAY[null::int, null::int, null::int, null::int]
    end;
$$
;
