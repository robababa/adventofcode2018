do
language plpgsql
$$
  declare
    carts bigint := 0;
    spots bigint := 0;
    cart day13_cart;
  begin
    select count(*) into carts from day13_cart;
    spots := day13_spots();
    loop
      for cart in (select * from day13_cart order by x, y) loop
        /*
        raise notice 'moving cart % from x = %, y = % with direction % and next_turn %',
          cart.id, cart.x, cart.y, cart.direction, cart.next_turn;
        */
        perform day13_move_cart(cart);
      end loop;
    end loop;
  end;
$$
;
