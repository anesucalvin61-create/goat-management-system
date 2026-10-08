-- Create the public profiles table if not already created
create table if not exists profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  created_at timestamptz default now()
);

-- Main goats table
create table if not exists goats (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  goat_number text not null,
  owner text not null,
  date_of_birth date not null,
  vaccination_date date not null,
  herd_size integer not null default 1,
  notes text default '',
  created_at timestamptz default now()
);

-- Optional vaccination events log
create table if not exists vaccinations (
  id uuid primary key default gen_random_uuid(),
  goat_id uuid references goats(id) on delete cascade not null,
  vaccine_name text not null,
  vaccination_date date not null,
  notes text default '',
  created_at timestamptz default now()
);

-- Goat photos storage relation
create table if not exists goat_photos (
  id uuid primary key default gen_random_uuid(),
  goat_id uuid references goats(id) on delete cascade not null,
  image_url text not null,
  created_at timestamptz default now()
);

-- Policies
alter table goats enable row level security;
alter table vaccinations enable row level security;
alter table goat_photos enable row level security;

create policy "Users can view their goats"
on goats
for select
using (auth.uid() = user_id);

create policy "Users can insert their goats"
on goats
for insert
with check (auth.uid() = user_id);

create policy "Users can update their goats"
on goats
for update
using (auth.uid() = user_id);

create policy "Users can delete their goats"
on goats
for delete
using (auth.uid() = user_id);

create policy "Users can view their vaccinations"
on vaccinations
for select
using (exists (
  select 1 from goats g where g.id = goat_id and g.user_id = auth.uid()
));

create policy "Users can manage their vaccinations"
on vaccinations
for all
using (exists (
  select 1 from goats g where g.id = goat_id and g.user_id = auth.uid()
))
with check (exists (
  select 1 from goats g where g.id = goat_id and g.user_id = auth.uid()
));

create policy "Users can manage their goat photos"
on goat_photos
for all
using (exists (
  select 1 from goats g where g.id = goat_id and g.user_id = auth.uid()
))
with check (exists (
  select 1 from goats g where g.id = goat_id and g.user_id = auth.uid()
));

-- Helpful indexes
create index if not exists goats_user_id_idx on goats(user_id);
create index if not exists goats_vaccination_date_idx on goats(vaccination_date);
create index if not exists vaccinations_goat_id_idx on vaccinations(goat_id);
