-- use psql for the \copy command
drop table if exists day01;

create table day01 (id serial, change int not null);

\copy day01 (change) from 'input.txt';

select sum(change) from day01;
