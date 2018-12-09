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

/*
do
language plpgsql
$$
declare
  entry day08;
  new_node day08_node;
  nodes int[];
  next_enum day08_next_read := 'node';
  md_counts int[];
  child_counts int[];
begin
  for entry in (select * from day08 order by id) loop
    if next_enum = 'node'
      then
        begin
          --           node ID   parent node ID (maybe null) child count metadata count
          new_node := (entry.id, nodes[cardinality(nodes)], entry.value, null);
          nodes := array_append(nodes, entry.id);
          child_counts := array_append(child_counts, entry.value);
          next_enum := 'md_count';
        end;

      elsif next_enum = 'md_count'
        then
          begin
            new_node.md_count := entry.value;
            raise notice 'inserting node id %, parent_id %, child_count %, md_count %',
              new_node.id, new_node.parent_id, new_node.child_count, new_node.md_count;
            insert into day08_node values (new_node.*);

            if new_node.child_count > 0
              then
                -- we're going to read a child node
                next_enum := 'node';
              elsif new_node.md_count > 0
                -- we're going to read metadata values
                then
                  next_enum := 'md_value';
                  md_counts := array_append(md_counts, new_node.md_count);
              else
                begin
                  -- the current node has no children, no metadata, so is not the parent of anything
                  -- pop it off of the nodes array, and get ready to read another node
                  while array_length(md_counts, 1) > 0 and md_counts[cardinality(md_counts)] = 0 loop
                    nodes := array_remove(nodes, nodes[cardinality(nodes)]);
                    md_counts := array_remove(md_counts, md_counts[cardinality(md_counts)]);
                  end loop;
                  next_enum := 'node';
                end;
            end if;
          end;

      elsif next_enum = 'md_value'
        then
          begin
            raise notice '-- inserting metadata node_id %, md_value %', new_node.id, entry.value;
            insert into day08_metadata (node_id, md_value) values (new_node.id, entry.value);
            md_counts[cardinality(md_counts)] := md_counts[cardinality(md_counts)] - 1;

            -- strip off all completed metadata searches (if parent metadata is empty, we might loop more than once)
            while array_length(md_counts, 1) > 0 and md_counts[cardinality(md_counts)] = 0 loop
              nodes := array_remove(nodes, nodes[cardinality(nodes)]);
              md_counts := array_remove(md_counts, md_counts[cardinality(md_counts)]);
            end loop;

            -- if we have no more metadata to search, then our next search value is a node
            if array_length(md_counts, 1) = 0
              then
                next_enum := 'node';
              else
                -- this is redundant, because next_enum is already set this way, but it helps readability
                next_enum := 'md_value';
            end if;
          end;
    end if;
  end loop;
end;
$$
;

select sum(md_value) from day08_metadata;
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

