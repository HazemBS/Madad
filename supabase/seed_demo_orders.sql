insert into public.orders (id, user_id, created_at, status, address, payment_method, notes, delivery_fee)
select 'MD-1048', id, now() - interval '1 day', 'outForDelivery',
       'حي النسيم، شارع الأمير بندر، الرياض', 'cashOnDelivery', '', 25
from public.profiles
where phone = '0512345678'
on conflict (id) do nothing;

insert into public.orders (id, user_id, created_at, status, address, payment_method, notes, delivery_fee)
select 'MD-1042', id, now() - interval '6 days', 'completed',
       'حي النسيم، شارع الأمير بندر، الرياض', 'bankTransfer', '', 25
from public.profiles
where phone = '0512345678'
on conflict (id) do nothing;

insert into public.order_items (order_id, product_id, name, supplier_name, unit_label, unit_price, quantity)
select 'MD-1048', 'p2', 'زيت دوار الشمس 1.8 لتر', 'واحة الغذاء للجملة', 'صندوق', 78, 2
where exists (select 1 from public.orders where id = 'MD-1048')
  and not exists (
    select 1 from public.order_items where order_id = 'MD-1048' and product_id = 'p2'
  );

insert into public.order_items (order_id, product_id, name, supplier_name, unit_label, unit_price, quantity)
select 'MD-1048', 'p6', 'رول حراري للكاشير', 'صفاء للجملة', 'صندوق', 45, 2
where exists (select 1 from public.orders where id = 'MD-1048')
  and not exists (
    select 1 from public.order_items where order_id = 'MD-1048' and product_id = 'p6'
  );

insert into public.order_items (order_id, product_id, name, supplier_name, unit_label, unit_price, quantity)
select 'MD-1042', 'p8', 'مناديل ورقية 150 منديل', 'صفاء للجملة', 'كرتون', 52, 2
where exists (select 1 from public.orders where id = 'MD-1042')
  and not exists (
    select 1 from public.order_items where order_id = 'MD-1042' and product_id = 'p8'
  );

insert into public.order_items (order_id, product_id, name, supplier_name, unit_label, unit_price, quantity)
select 'MD-1042', 'p12', 'أقلام حبر جاف أزرق', 'بيت الجملة', 'صندوق', 14, 4
where exists (select 1 from public.orders where id = 'MD-1042')
  and not exists (
    select 1 from public.order_items where order_id = 'MD-1042' and product_id = 'p12'
  );
