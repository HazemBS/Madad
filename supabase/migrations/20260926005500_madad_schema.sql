-- جداول سوق مَدَد: كتالوج عام، وحساب المتجر، والمفضلة، والطلبات.

create table if not exists public.categories (
  id text primary key,
  name text not null,
  icon text not null
);

create table if not exists public.suppliers (
  id text primary key,
  name text not null,
  city text not null,
  rating numeric(2, 1) not null,
  verified boolean not null default true,
  about text not null
);

create table if not exists public.supplier_categories (
  supplier_id text not null references public.suppliers (id) on delete cascade,
  category_id text not null references public.categories (id) on delete cascade,
  primary key (supplier_id, category_id)
);

create table if not exists public.products (
  id text primary key,
  name text not null,
  description text not null,
  wholesale_price numeric(12, 2) not null,
  unit text not null check (unit in ('carton', 'box', 'piece', 'kilo')),
  min_order integer not null check (min_order > 0),
  stock integer not null check (stock >= 0),
  supplier_id text not null references public.suppliers (id),
  category_id text not null references public.categories (id),
  is_popular boolean not null default false
);

create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  business_name text not null,
  owner_name text not null,
  phone text not null,
  city text not null,
  address text not null
);

create table if not exists public.favorites (
  user_id uuid not null references auth.users (id) on delete cascade,
  product_id text not null references public.products (id) on delete cascade,
  primary key (user_id, product_id)
);

create sequence if not exists public.order_number_seq start with 1049;

create table if not exists public.orders (
  id text primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  created_at timestamptz not null default now(),
  status text not null check (
    status in ('created', 'confirmed', 'preparing', 'outForDelivery', 'completed')
  ),
  address text not null,
  payment_method text not null check (
    payment_method in ('cashOnDelivery', 'bankTransfer')
  ),
  notes text not null default '',
  delivery_fee numeric(12, 2) not null default 0
);

create table if not exists public.order_items (
  id bigint generated always as identity primary key,
  order_id text not null references public.orders (id) on delete cascade,
  product_id text not null,
  name text not null,
  supplier_name text not null,
  unit_label text not null,
  unit_price numeric(12, 2) not null,
  quantity integer not null check (quantity > 0)
);

create or replace function public.next_order_id()
returns text
language sql
security definer
set search_path = public
as $$
  select 'MD-' || nextval('public.order_number_seq')::text;
$$;

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, business_name, owner_name, phone, city, address)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'business_name', 'بقالة النور'),
    coalesce(new.raw_user_meta_data ->> 'owner_name', 'خالد العمري'),
    coalesce(new.raw_user_meta_data ->> 'phone', '0512345678'),
    coalesce(new.raw_user_meta_data ->> 'city', 'الرياض'),
    coalesce(new.raw_user_meta_data ->> 'address', 'حي النسيم، شارع الأمير بندر، الرياض')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

alter table public.categories enable row level security;
alter table public.suppliers enable row level security;
alter table public.supplier_categories enable row level security;
alter table public.products enable row level security;
alter table public.profiles enable row level security;
alter table public.favorites enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;

grant select on public.categories, public.suppliers, public.supplier_categories, public.products to anon, authenticated;
grant select, update on public.profiles to authenticated;
grant select, insert, delete on public.favorites to authenticated;
grant select, insert on public.orders, public.order_items to authenticated;
grant execute on function public.next_order_id() to authenticated;

drop policy if exists "catalog categories read" on public.categories;
create policy "catalog categories read" on public.categories
  for select to anon, authenticated using (true);

drop policy if exists "catalog suppliers read" on public.suppliers;
create policy "catalog suppliers read" on public.suppliers
  for select to anon, authenticated using (true);

drop policy if exists "catalog supplier categories read" on public.supplier_categories;
create policy "catalog supplier categories read" on public.supplier_categories
  for select to anon, authenticated using (true);

drop policy if exists "catalog products read" on public.products;
create policy "catalog products read" on public.products
  for select to anon, authenticated using (true);

drop policy if exists "own profile read" on public.profiles;
create policy "own profile read" on public.profiles
  for select to authenticated using (id = auth.uid());

drop policy if exists "own profile update" on public.profiles;
create policy "own profile update" on public.profiles
  for update to authenticated using (id = auth.uid());

drop policy if exists "own favorites read" on public.favorites;
create policy "own favorites read" on public.favorites
  for select to authenticated using (user_id = auth.uid());

drop policy if exists "own favorites insert" on public.favorites;
create policy "own favorites insert" on public.favorites
  for insert to authenticated with check (user_id = auth.uid());

drop policy if exists "own favorites delete" on public.favorites;
create policy "own favorites delete" on public.favorites
  for delete to authenticated using (user_id = auth.uid());

drop policy if exists "own orders read" on public.orders;
create policy "own orders read" on public.orders
  for select to authenticated using (user_id = auth.uid());

drop policy if exists "own orders insert" on public.orders;
create policy "own orders insert" on public.orders
  for insert to authenticated with check (user_id = auth.uid());

drop policy if exists "own order items read" on public.order_items;
create policy "own order items read" on public.order_items
  for select to authenticated using (
    exists (
      select 1 from public.orders
      where orders.id = order_items.order_id
        and orders.user_id = auth.uid()
    )
  );

drop policy if exists "own order items insert" on public.order_items;
create policy "own order items insert" on public.order_items
  for insert to authenticated with check (
    exists (
      select 1 from public.orders
      where orders.id = order_items.order_id
        and orders.user_id = auth.uid()
    )
  );

insert into public.categories (id, name, icon) values
  ('c1', 'أغذية ومشروبات', 'food'),
  ('c2', 'مستلزمات المتاجر', 'store'),
  ('c3', 'عناية ونظافة', 'care'),
  ('c4', 'أدوات منزلية', 'home'),
  ('c5', 'إلكترونيات', 'electronics'),
  ('c6', 'قرطاسية', 'stationery')
on conflict (id) do update set name = excluded.name, icon = excluded.icon;

insert into public.suppliers (id, name, city, rating, verified, about) values
  ('s1', 'واحة الغذاء للجملة', 'الرياض', 4.8, true, 'توريد أغذية جافة ومشروبات للمتاجر منذ عام 2012، مع التزام بمواعيد التسليم.'),
  ('s2', 'صفاء للجملة', 'جدة', 4.6, true, 'مستلزمات تشغيل المتاجر ومنتجات العناية والنظافة بأسعار جملة واضحة.'),
  ('s3', 'بيت الجملة', 'الدمام', 4.5, true, 'أدوات منزلية وإلكترونيات وقرطاسية جاهزة للتوريد إلى المتاجر المتوسطة.')
on conflict (id) do update set
  name = excluded.name,
  city = excluded.city,
  rating = excluded.rating,
  verified = excluded.verified,
  about = excluded.about;

insert into public.supplier_categories (supplier_id, category_id) values
  ('s1', 'c1'),
  ('s2', 'c2'),
  ('s2', 'c3'),
  ('s3', 'c4'),
  ('s3', 'c5'),
  ('s3', 'c6')
on conflict do nothing;

insert into public.products (
  id, name, description, wholesale_price, unit, min_order, stock, supplier_id, category_id, is_popular
) values
  ('p1', 'أرز بسمتي هندي 10 كجم', 'أرز بسمتي طويل الحبة، الكرتون يضم 4 أكياس. مناسب للبقالات والمطاعم الصغيرة.', 96, 'carton', 2, 80, 's1', 'c1', true),
  ('p2', 'زيت دوار الشمس 1.8 لتر', 'صندوق من 6 عبوات زيت نباتي للطبخ. يُحفظ في مكان جاف بعيدًا عن الشمس.', 78, 'box', 1, 60, 's1', 'c1', true),
  ('p3', 'تمر سكري فاخر', 'تمر سكري طازج يُباع بالكيلو. الحد الأدنى مناسب لتعبئة أرفف التمور.', 28, 'kilo', 5, 200, 's1', 'c1', false),
  ('p4', 'مياه شرب 330 مل', 'صندوق مياه معبأ يضم 40 عبوة. خيار سريع لحركة البيع اليومية.', 16, 'box', 10, 150, 's1', 'c1', false),
  ('p5', 'أكياس تسوق وسط', 'كرتون يضم 500 كيس تسوق متوسط للمتاجر. سماكة مناسبة للاستخدام اليومي.', 32, 'carton', 3, 90, 's2', 'c2', false),
  ('p6', 'رول حراري للكاشير', 'صندوق من 50 رولًا بمقاس 80 ملم. متوافق مع أجهزة الكاشير الشائعة.', 45, 'box', 2, 40, 's2', 'c2', true),
  ('p7', 'صابون سائل لليدين 4 لتر', 'عبوة عملية لدورات المياه وكاونتر الخدمة. رائحة خفيفة وسريعة الشطف.', 18, 'piece', 6, 70, 's2', 'c3', true),
  ('p8', 'مناديل ورقية 150 منديل', 'كرتون من 24 عبوة مناديل ناعمة. مناسب للبقالات والصيدليات.', 52, 'carton', 2, 55, 's2', 'c3', true),
  ('p9', 'طقم استكانات شاي', 'صندوق يضم 12 طقمًا من الاستكانات الزجاجية. يتحمل التقديم اليومي.', 110, 'box', 1, 25, 's3', 'c4', true),
  ('p10', 'لمبة LED 12 واط', 'كرتون من 20 لمبة إضاءة بيضاء. استهلاك منخفض وعمر تشغيلي طويل.', 64, 'carton', 1, 35, 's3', 'c5', false),
  ('p11', 'شاحن جداري منفذين', 'شاحن مزدوج للهواتف. يُباع بالحبة مع حد أدنى يناسب رف الإكسسوارات.', 24, 'piece', 8, 100, 's3', 'c5', false),
  ('p12', 'أقلام حبر جاف أزرق', 'صندوق من 50 قلمًا للكتابة اليومية. خيار ثابت لقسم القرطاسية.', 14, 'box', 4, 120, 's3', 'c6', true)
on conflict (id) do update set
  name = excluded.name,
  description = excluded.description,
  wholesale_price = excluded.wholesale_price,
  unit = excluded.unit,
  min_order = excluded.min_order,
  stock = excluded.stock,
  supplier_id = excluded.supplier_id,
  category_id = excluded.category_id,
  is_popular = excluded.is_popular;
