create  or replace function day08_node_value(node_id_in int) returns numeric
language sql
as
  $$
    with children as (
      select
        node_id,
        rank() over (order by node_id) as birth_order
      from day08_node
      where parent_id = node_id_in order by node_id
    ),
    metadata as (
      select
        md_value
      from day08_metadata
      where node_id = node_id_in
    ),
    childless as (
      select sum(md_value) as value
      from day08_metadata
      where node_id = node_id_in
    ),
    child_bearing as (
      select
        sum(day08_node_value(children.node_id)) as value
      from
      children inner join metadata
        on children.birth_order = metadata.md_value
    )
    select
    case
      when ((select count(*) from children) > 0)
      then (select value from child_bearing)
      else (select value from childless)
    end;
  $$
;

select day08_node_value(1);
