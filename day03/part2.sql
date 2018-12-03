drop table if exists day03_min_max;

create table day03_min_max (
  from_left integer not null,
  from_top integer not null,
  min_claim_id bigint not null,
  max_claim_id bigint not null
);

insert into day03_min_max
(from_left, from_top, min_claim_id, max_claim_id)
select
from_left, from_top, min(claim_id), max(claim_id)
from
day03_squares
group by
from_left, from_top;

select id from day03
where
not exists(
  select
  from
  day03_squares as sq inner join
    day03_min_max as mm
      on sq.from_left = mm.from_left and sq.from_top = mm.from_top
  where
  sq.claim_id = day03.id and
    (sq.claim_id <> mm.min_claim_id or sq.claim_id <> mm.max_claim_id)
);
