create or replace function day13_spots() returns bigint
language sql
as
$$
select count(distinct(x,y)) from day13_cart;
$$
;

create or replace function day13_next_turn(current_turn text) returns text
language sql
as
$$
  select
    case current_turn
        when 'left' then 'straight'
        when 'straight' then 'right'
        when 'right' then 'left'
    end;
$$
;

create or replace function day13_next_direction(next_x int, next_y int, current_direction text, current_turn text) returns text
  language sql
as
$$
  with next_track as (
    select * from day13_grid where x = next_x and y = next_y
  )
  select
  case track
      when '+' then
          case
              when current_turn = 'straight' then current_direction
              when current_turn = 'left' and current_direction = 'N' then 'W'
              when current_turn = 'left' and current_direction = 'W' then 'S'
              when current_turn = 'left' and current_direction = 'S' then 'E'
              when current_turn = 'left' and current_direction = 'E' then 'N'
              when current_turn = 'right' and current_direction = 'N' then 'E'
              when current_turn = 'right' and current_direction = 'E' then 'S'
              when current_turn = 'right' and current_direction = 'S' then 'W'
              when current_turn = 'right' and current_direction = 'W' then 'N'
          end
      when '/' then
          case current_direction
              when 'N' then 'E'
              when 'W' then 'S'
          end
      when '\' then
          case current_direction
              when 'S' then 'E'
              when 'W' then 'N'
          end
  end
  from next_track;
$$
;

create or replace function day13_move_cart(cart day13_cart) returns void
language sql
as
$$
  with next_points as (
    select
      case cart.direction
          when 'E' then cart.x + 1
          when 'W' then cart.x - 1
          else cart.x
      end as x,
      case cart.direction
          when 'S' then cart.y + 1
          when 'N' then cart.y - 1
          else cart.y
      end as y
  )
  update day13_cart
  set
    (x, y, direction, next_turn) =
    (
      select
        next_points.x,
        next_points.y,
        day13_next_direction(next_points.x, next_points.y, cart.direction, cart.next_turn),
        case
            when (select track from day13_grid as g inner join next_points as n on g.x = n.x and g.y = n.y) = '+'
            then day13_next_turn(next_turn)
            else next_turn
        end
    )
  from next_points
  where
  day13_cart.x = next_points.x and
  day13_cart.y = next_points.y;
$$
;

/*
do
language plpgsql
$$
  declare
    carts bigint := 0;
    spots bigint := 0;
    cart day13_cart;
    round bigint := 0;
  begin
    select count(*) into carts from day13_cart;
    spots := day13_spots();
    loop
      for cart in (select * from day13_cart order by x, y) loop
        perform day13_move_cart(cart);
      end loop;
    end loop;
  end;
$$
;
*/
