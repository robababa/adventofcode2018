insert into day16_match (result_id, code_id)
select
r.id, c.id
from
day16_result as r cross join day16_operation_code as c
where
ARRAY[r.after_0, r.after_1, r.after_2, r.after_3] =
day16_operation(c.code, r.input_a, r.input_b, r.output_c, r.before_0, r.before_1, r.before_2, r.before_3);

with source as (
  select result_id, count(*) as matches from day16_match group by result_id
)
select count(*) as part1_answer from source where matches >= 3;
