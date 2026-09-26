-- أدوار الحساب، ملكية منتجات المورد، وإنشاء الطلب بسعر الخادم.
-- لا تُعطَّل سياسات الصفوف. الإدراج المباشر للطلب يُسحب حتى لا يرسل الجهاز السعر.

alter table public.profiles
  add column if not exists role text not null default 'customer';

alter table public.profiles
  drop constraint if exists profiles_role_check;

alter table public.profiles
  add constraint profiles_role_check check (role in ('customer', 'supplier'));

alter table public.profiles
  add column if not exists supplier_id text references public.suppliers (id);

update public.profiles
set role = 'customer'
where role is null or role not in ('customer', 'supplier');

alter table public.products
  drop constraint if exists products_wholesale_price_positive;

alter table public.products
  add constraint products_wholesale_price_positive check (wholesale_price > 0);

create or replace function public.protect_profile_privileges()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if auth.uid() is not null then
    if new.role is distinct from old.role then
      raise exception 'لا يمكن تغيير الدور من التطبيق.';
    end if;
    if new.supplier_id is distinct from old.supplier_id then
      raise exception 'لا يمكن تغيير ربط المورد من التطبيق.';
    end if;
  end if;
  return new;
end;
$$;

drop trigger if exists protect_profile_privileges on public.profiles;
create trigger protect_profile_privileges
  before update on public.profiles
  for each row execute function public.protect_profile_privileges();

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  requested_role text := coalesce(new.raw_user_meta_data ->> 'role', 'customer');
  supplier_key text;
  business_name text := coalesce(nullif(new.raw_user_meta_data ->> 'business_name', ''), 'منشأة جديدة');
  owner_name text := coalesce(nullif(new.raw_user_meta_data ->> 'owner_name', ''), 'صاحب المنشأة');
  phone text := coalesce(nullif(new.raw_user_meta_data ->> 'phone', ''), '0500000000');
  city text := coalesce(nullif(new.raw_user_meta_data ->> 'city', ''), 'الرياض');
  address text := coalesce(nullif(new.raw_user_meta_data ->> 'address', ''), city);
begin
  if requested_role <> 'supplier' then
    requested_role := 'customer';
  end if;

  if requested_role = 'supplier' then
    supplier_key := 's-' || replace(new.id::text, '-', '');
    insert into public.suppliers (id, name, city, rating, verified, about)
    values (supplier_key, business_name, city, 0, false, 'حساب مورد جديد')
    on conflict (id) do nothing;
    insert into public.profiles (
      id, business_name, owner_name, phone, city, address, role, supplier_id
    )
    values (
      new.id, business_name, owner_name, phone, city, address, 'supplier', supplier_key
    )
    on conflict (id) do nothing;
  else
    insert into public.profiles (
      id, business_name, owner_name, phone, city, address, role, supplier_id
    )
    values (
      new.id, business_name, owner_name, phone, city, address, 'customer', null
    )
    on conflict (id) do nothing;
  end if;
  return new;
end;
$$;

drop policy if exists "own profile update" on public.profiles;
create policy "own profile update" on public.profiles
  for update to authenticated
  using (id = auth.uid())
  with check (id = auth.uid());

drop policy if exists "supplier inserts own products" on public.products;
create policy "supplier inserts own products" on public.products
  for insert to authenticated
  with check (
    exists (
      select 1 from public.profiles
      where profiles.id = auth.uid()
        and profiles.role = 'supplier'
        and profiles.supplier_id is not null
        and profiles.supplier_id = supplier_id
    )
  );

drop policy if exists "supplier updates own products" on public.products;
create policy "supplier updates own products" on public.products
  for update to authenticated
  using (
    exists (
      select 1 from public.profiles
      where profiles.id = auth.uid()
        and profiles.role = 'supplier'
        and profiles.supplier_id is not null
        and profiles.supplier_id = supplier_id
    )
  )
  with check (
    exists (
      select 1 from public.profiles
      where profiles.id = auth.uid()
        and profiles.role = 'supplier'
        and profiles.supplier_id is not null
        and profiles.supplier_id = supplier_id
    )
  );

drop policy if exists "supplier deletes own products" on public.products;
create policy "supplier deletes own products" on public.products
  for delete to authenticated
  using (
    exists (
      select 1 from public.profiles
      where profiles.id = auth.uid()
        and profiles.role = 'supplier'
        and profiles.supplier_id is not null
        and profiles.supplier_id = supplier_id
    )
  );

drop policy if exists "supplier links own categories" on public.supplier_categories;
create policy "supplier links own categories" on public.supplier_categories
  for insert to authenticated
  with check (
    exists (
      select 1 from public.profiles
      where profiles.id = auth.uid()
        and profiles.role = 'supplier'
        and profiles.supplier_id is not null
        and profiles.supplier_id = supplier_id
    )
  );

drop policy if exists "own orders insert" on public.orders;
drop policy if exists "own order items insert" on public.order_items;

drop policy if exists "own orders read" on public.orders;
create policy "own orders read" on public.orders
  for select to authenticated
  using (
    user_id = auth.uid()
    or exists (
      select 1
      from public.order_items
      join public.products on products.id = order_items.product_id
      join public.profiles on profiles.supplier_id = products.supplier_id
      where order_items.order_id = orders.id
        and profiles.id = auth.uid()
        and profiles.role = 'supplier'
    )
  );

drop policy if exists "own order items read" on public.order_items;
create policy "own order items read" on public.order_items
  for select to authenticated
  using (
    exists (
      select 1 from public.orders
      where orders.id = order_items.order_id
        and (
          orders.user_id = auth.uid()
          or exists (
            select 1
            from public.products
            join public.profiles on profiles.supplier_id = products.supplier_id
            where products.id = order_items.product_id
              and profiles.id = auth.uid()
              and profiles.role = 'supplier'
          )
        )
    )
  );

revoke insert on public.orders from anon, authenticated;
revoke insert on public.order_items from anon, authenticated;

grant insert, update, delete on public.products to authenticated;
grant insert on public.supplier_categories to authenticated;

create or replace function public.create_secure_order(
  p_items jsonb,
  p_address text,
  p_payment_method text,
  p_notes text
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  item jsonb;
  product_id text;
  quantity integer;
  product_row public.products%rowtype;
  supplier_name text;
  unit_label text;
  subtotal numeric(12, 2) := 0;
  delivery_fee numeric(12, 2);
  order_id text;
  items_json jsonb := '[]'::jsonb;
begin
  if uid is null then
    raise exception 'سجّل الدخول قبل تأكيد الطلب.';
  end if;
  if p_address is null or length(trim(p_address)) = 0 then
    raise exception 'عنوان التوصيل مطلوب.';
  end if;
  if p_payment_method not in ('cashOnDelivery', 'bankTransfer') then
    raise exception 'طريقة الدفع غير مدعومة.';
  end if;
  if p_items is null or jsonb_typeof(p_items) <> 'array' or jsonb_array_length(p_items) = 0 then
    raise exception 'لا يمكن إنشاء طلب من سلة فارغة';
  end if;
  if exists (
    select 1
    from jsonb_array_elements(p_items) as entry
    group by entry ->> 'product_id'
    having count(*) > 1
  ) then
    raise exception 'تكرر منتج داخل الطلب.';
  end if;

  for item in select value from jsonb_array_elements(p_items)
  loop
    product_id := item ->> 'product_id';
    if product_id is null or product_id = '' then
      raise exception 'منتج غير متاح.';
    end if;
    if coalesce(item ->> 'quantity', '') !~ '^[0-9]+$' then
      raise exception 'الكمية غير صالحة.';
    end if;
    quantity := (item ->> 'quantity')::integer;
    select * into product_row from public.products where id = product_id;
    if not found then
      raise exception 'منتج غير متاح.';
    end if;
    if quantity < product_row.min_order or quantity > product_row.stock then
      raise exception 'الكمية غير صالحة أو غير متوفرة.';
    end if;
    subtotal := subtotal + (product_row.wholesale_price * quantity);
  end loop;

  delivery_fee := case when subtotal >= 500 then 0 else 25 end;
  order_id := public.next_order_id();

  insert into public.orders (
    id, user_id, status, address, payment_method, notes, delivery_fee
  )
  values (
    order_id,
    uid,
    'created',
    trim(p_address),
    p_payment_method,
    coalesce(p_notes, ''),
    delivery_fee
  );

  for item in select value from jsonb_array_elements(p_items)
  loop
    product_id := item ->> 'product_id';
    quantity := (item ->> 'quantity')::integer;
    select * into product_row
    from public.products
    where id = product_id
    for update;
    if not found or quantity > product_row.stock then
      raise exception 'الكمية المتوفرة لا تكفي.';
    end if;
    select name into supplier_name
    from public.suppliers
    where id = product_row.supplier_id;
    unit_label := case product_row.unit
      when 'carton' then 'كرتون'
      when 'box' then 'صندوق'
      when 'piece' then 'حبة'
      when 'kilo' then 'كيلو'
      else product_row.unit
    end;
    insert into public.order_items (
      order_id, product_id, name, supplier_name, unit_label, unit_price, quantity
    )
    values (
      order_id,
      product_row.id,
      product_row.name,
      coalesce(supplier_name, ''),
      unit_label,
      product_row.wholesale_price,
      quantity
    );
    update public.products
    set stock = stock - quantity
    where id = product_row.id;
    items_json := items_json || jsonb_build_array(
      jsonb_build_object(
        'product_id', product_row.id,
        'name', product_row.name,
        'supplier_name', coalesce(supplier_name, ''),
        'unit_label', unit_label,
        'unit_price', product_row.wholesale_price,
        'quantity', quantity
      )
    );
  end loop;

  return jsonb_build_object(
    'id', order_id,
    'created_at', now(),
    'status', 'created',
    'address', trim(p_address),
    'payment_method', p_payment_method,
    'notes', coalesce(p_notes, ''),
    'delivery_fee', delivery_fee,
    'order_items', items_json
  );
end;
$$;

revoke all on function public.create_secure_order(jsonb, text, text, text) from public;
grant execute on function public.create_secure_order(jsonb, text, text, text) to authenticated;
