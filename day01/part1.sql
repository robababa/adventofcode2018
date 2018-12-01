-- use psql for the \copy command
drop table if exists day01;

create table day01 (change int not null);

\copy day01 from 'input.txt';

select sum(change) from day01;
