drop table if exists day08, day08_node, day08_metadata;
drop type if exists day08_enum;

create table day08 (
  id serial not null primary key,
  value int not null
);

\copy day08 (value) from program './load.bash';

create type day08_enum as enum ('node', 'md_count', 'md_value');

create table day08_node (
  id int not null primary key references day08,
  parent_id int null,
  child_count int not null,
  md_count int not null
);

create table day08_metadata (
  id serial not null primary key,
  node_id int not null references day08_node,
  md_value int not null
);

-- create an index that guarantees at most one root node
create unique index day08_node__unique_root_idx on day08_node ((1)) where parent_id is null;

do
language plpgsql
$$
declare
  entry day08;
  new_node day08_node;
  nodes int[];
  next_enum day08_enum := 'node';
  md_entries int := 0;
begin
  for entry in (select * from day08 order by id) loop
    if next_enum = 'node'
      then
        begin
          --           node ID   parent node ID (maybe null)    child count  metadata count
          new_node := (entry.id, nodes[cardinality(nodes)], entry.value, null);
          nodes := array_append(nodes, entry.id);
          next_enum := 'md_count';
        end;

      elsif next_enum = 'md_count'
        then
          begin
            new_node.md_count := entry.value;
            raise notice 'inserting node id %, parent_id %, child_count %, md_count %', new_node.id, new_node.parent_id, new_node.child_count, new_node.md_count;
            insert into day08_node values (new_node.*);
            md_entries := entry.value;

            if new_node.child_count > 0
              then
                next_enum := 'node';
              elsif new_node.md_count > 0
                then
                  next_enum := 'md_value';
              else
                begin
                  -- node has no children, no metadata, so is not the parent of anything
                  -- pop it off of the nodes array, and get ready to read another node
                  nodes := array_remove(nodes, nodes[cardinality(nodes)]);
                  next_enum := 'node';
                end;
            end if;
          end;

      elsif next_enum = 'md_value'
        then
          begin
            raise notice '-- inserting metadata node_id %, md_value %', new_node.id, entry.value;
            insert into day08_metadata (node_id, md_value) values (new_node.id, entry.value);
            md_entries := md_entries - 1;
            if md_entries = 0
              then
                next_enum := 'node';
              else
                next_enum := 'md_value';
            end if;
          end;
    end if;
  end loop;
end;
$$
;

select sum(md_value) from day08_metadata;
