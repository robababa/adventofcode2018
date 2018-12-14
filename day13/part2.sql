alter table day13_cart drop constraint uk_day13_cart_x_y;

create table day13_cart_crashed (
  cart_id int not null primary key,
  crashed boolean not null default false,
  constraint fk_day13_cart_crashed__cart_id foreign key (cart_id) references day13_cart (id)
);

insert into day13_cart_crashed (cart_id, crashed) select id, false from day13_cart;

do
  language plpgsql
    $$
    declare
      not_crashed bigint := 0;
      cart day13_cart;
      affected bigint := 0;
    begin
      select count(*) into not_crashed from day13_cart_crashed;
      raise notice '% carts to begin with', not_crashed;
      loop
        exit when not_crashed <= 1;

        for cart in (select * from day13_cart order by x, y) loop
          perform day13_move_cart(cart);
          update day13_cart_crashed as upd
            set crashed = true
            from
                 day13_cart as this_cart
                   inner join day13_cart that_cart
                     on this_cart.id <> that_cart.id and this_cart.x = that_cart.x and this_cart.y = that_cart.y
                   inner join day13_cart_crashed as other_not_crashed
                     on that_cart.id = other_not_crashed.cart_id and other_not_crashed.crashed = false
            where
                  this_cart.id = upd.cart_id and
                  upd.crashed = false;

          get diagnostics affected := row_count;
          if affected > 0
            then
              raise notice 'crashed % carts', affected;
              affected := 0;
              select count(*) into not_crashed from day13_cart_crashed where not crashed;
              raise notice '% non-crashed carts left', not_crashed;
          end if;
        end loop;
      end loop;
    end;
    $$
;

select cart.*
from day13_cart as cart
  inner join day13_cart_crashed as not_crashed on cart.id = not_crashed.cart_id
where
not_crashed.crashed = false;
