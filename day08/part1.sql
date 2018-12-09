drop function if exists insert_node, update_node, insert_metadata;
drop table if exists day08_values, day08_node, day08_metadata;
drop type if exists day08_next_read;

create table day08_values (
  id serial not null primary key,
  value int not null
);

\copy day08_values (value) from program './load.bash';

create table day08_node (
  node_id int not null primary key references day08_values,
  parent_id int null references day08_node (node_id),
  child_count int not null,
  md_count int null
);

create table day08_metadata (
  id serial not null primary key,
  node_id int not null references day08_node,
  md_value int not null
);

create type day08_next_read as enum ('insert_node', 'update_node', 'insert_metadata');

do
language plpgsql
$$
declare
  entry day08_values;
  current_node day08_node;
  declare aux day08_node;
  nodes day08_node[];
  next_enum day08_next_read := 'insert_node';
begin
  for entry in (select * from day08_values order by id) loop
    if next_enum = 'insert_node'
      then
        --           node ID   parent node ID (nullable)              child count  metadata count
        current_node := (entry.id, nodes[cardinality(nodes)].node_id, entry.value, null);
        raise notice 'inserting node id %, parent_id %, child_count %, md_count %',
          current_node.node_id, current_node.parent_id, current_node.child_count, current_node.md_count;
        insert into day08_node values (current_node.*);
        -- if this node has a parent, i.e. is not the root node, then decrement its parent's child count now
        if array_length(nodes, 1) > 0
          then
            aux := nodes[cardinality(nodes)];
            aux.child_count := aux.child_count - 1;
            nodes[cardinality(nodes)] := aux;
        end if;
        nodes := array_append(nodes, current_node);
        next_enum := 'update_node';
        continue;
    end if;

    if next_enum = 'update_node'
      then
        current_node.md_count := entry.value;
        raise notice 'updating node id % with md_count %', current_node.node_id, current_node.md_count;
        update day08_node set md_count = current_node.md_count where node_id = current_node.node_id;
        aux := nodes[cardinality(nodes)];
        aux.md_count := current_node.md_count;
        nodes[cardinality(nodes)] := aux;

        -- pop off nodes with no remaining children or metadata
        while nodes[cardinality(nodes)].md_count = 0 and nodes[cardinality(nodes)].child_count = 0 loop
          nodes := array_remove(nodes, nodes[cardinality(nodes)]);
          current_node := nodes[cardinality(nodes)];
        end loop;

        -- if our array is empty now, the next thing is to read another node
        -- this should never happen, since we always have a root node until the end
        case
          when array_length(nodes, 1) = 0   then next_enum := 'insert_node';
          when current_node.child_count > 0 then next_enum := 'insert_node';
          when current_node.md_count > 0    then next_enum := 'insert_metadata';
        end case;
        continue;
    end if;


    -- next_enum is an 'md_value'
    raise notice '-- inserting metadata node_id %, md_value %', current_node.node_id, entry.value;
    insert into day08_metadata (node_id, md_value) values (current_node.node_id, entry.value);
    aux := nodes[cardinality(nodes)];
    aux.md_count := aux.md_count - 1;
    nodes[cardinality(nodes)] := aux;

    -- pop off nodes with no remaining children or metadata
    while nodes[cardinality(nodes)].md_count = 0 and nodes[cardinality(nodes)].child_count = 0 loop
      nodes := array_remove(nodes, nodes[cardinality(nodes)]);
      current_node := nodes[cardinality(nodes)];
    end loop;

    case
      when array_length(nodes, 1) = 0   then next_enum := 'insert_node';
      when current_node.child_count > 0 then next_enum := 'insert_node';
      when current_node.md_count > 0    then next_enum := 'insert_metadata';
    end case;
  end loop;
end;
$$
;

select sum(md_value) from day08_metadata;

/*
create or replace function insert_node(values_id_in int, parent_id_in int) returns void
language sql
as
  $$
    insert into day08_node (node_id, parent_id, child_count)
    select id, parent_id_in, value from day08_values where id = values_id_in;
  $$
;

create or replace function update_node(values_id_in int, node_id_in int) returns void
language sql
as
  $$
    update day08_node
    set md_count = (select value from day08_values where id = values_id_in)
    where node_id = node_id_in;
  $$
;

create or replace function insert_metadata(values_id_in int, node_id_in int) returns void
language sql
as
  $$
    insert into day08_metadata (node_id, md_value)
    select node_id_in, value from day08_values where id = values_id_in;
  $$
;

create or replace function what_to_do_next() returns day08_next_read
language plpgsql
as
  $$
    declare
      day08_value day08_values;
      next_read day08_next_read := 'insert_node';

    begin
      for day08_value in (select * from day08_values order by id) loop
      if next_read = 'insert_node'
        then
          perform insert_node()
      end if;
      select count(*) into node_count from day08_node;
      if node_count = 0 then return 'insert_node'::day08_next_read; end if;

      -- if the latest incomplete node is missing children, we should look for children
      select count(*) into missing_children_count from day08_node
      end loop;
    end;
  $$
;
*/

/*
if next is node - read node
if next is md_count - read md_count
if next is md_value - read md_value

read node
insert node with child count value, null md_count
also update parent node, decrementing child count, if there is a parent

read md_count - update node value with md_count, remaining_md
read md_value - insert into md table

big query to decide what to do next
*/

