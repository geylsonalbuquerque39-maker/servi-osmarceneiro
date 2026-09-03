-- CONTROLE DO MARCENEIRO
-- Pode executar este arquivo novamente para instalar atualizações.
-- Supabase: SQL Editor > New query > Run.

create extension if not exists pgcrypto;

create table if not exists public.servicos (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  category text not null check (category in ('paraiba', 'pessoal')),
  service_date date not null default current_date,
  client text not null,
  service text not null,
  environment text,
  quantity integer not null default 1 check (quantity > 0),
  unit_value numeric(12,2) not null default 0 check (unit_value >= 0),
  total numeric(12,2) not null default 0 check (total >= 0),
  payment text not null default 'Pix',
  received text not null default 'nao' check (received in ('sim', 'parcial', 'nao')),
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists servicos_user_date_idx
  on public.servicos (user_id, service_date desc);

create table if not exists public.service_photos (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  service_id uuid not null references public.servicos(id) on delete cascade,
  storage_path text not null unique,
  file_name text not null,
  mime_type text not null,
  size_bytes bigint not null default 0,
  created_at timestamptz not null default now()
);

create index if not exists service_photos_service_idx
  on public.service_photos (service_id, created_at);

alter table public.servicos enable row level security;
alter table public.service_photos enable row level security;

drop policy if exists "Usuarios leem seus servicos" on public.servicos;
create policy "Usuarios leem seus servicos"
  on public.servicos for select
  to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists "Usuarios criam seus servicos" on public.servicos;
create policy "Usuarios criam seus servicos"
  on public.servicos for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

drop policy if exists "Usuarios alteram seus servicos" on public.servicos;
create policy "Usuarios alteram seus servicos"
  on public.servicos for update
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

drop policy if exists "Usuarios excluem seus servicos" on public.servicos;
create policy "Usuarios excluem seus servicos"
  on public.servicos for delete
  to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists "Usuarios leem suas fotos" on public.service_photos;
create policy "Usuarios leem suas fotos"
  on public.service_photos for select
  to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists "Usuarios criam suas fotos" on public.service_photos;
create policy "Usuarios criam suas fotos"
  on public.service_photos for insert
  to authenticated
  with check (
    (select auth.uid()) = user_id
    and exists (
      select 1 from public.servicos
      where servicos.id = service_photos.service_id
        and servicos.user_id = (select auth.uid())
    )
  );

drop policy if exists "Usuarios excluem suas fotos" on public.service_photos;
create policy "Usuarios excluem suas fotos"
  on public.service_photos for delete
  to authenticated
  using ((select auth.uid()) = user_id);

-- Bucket privado: as fotos não recebem endereço público permanente.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'service-photos',
  'service-photos',
  false,
  6291456,
  array['image/jpeg', 'image/png', 'image/webp', 'image/heic', 'image/heif']
)
on conflict (id) do update set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "Usuarios visualizam seus arquivos" on storage.objects;
create policy "Usuarios visualizam seus arquivos"
  on storage.objects for select
  to authenticated
  using (
    bucket_id = 'service-photos'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

drop policy if exists "Usuarios enviam seus arquivos" on storage.objects;
create policy "Usuarios enviam seus arquivos"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'service-photos'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

drop policy if exists "Usuarios alteram seus arquivos" on storage.objects;
create policy "Usuarios alteram seus arquivos"
  on storage.objects for update
  to authenticated
  using (
    bucket_id = 'service-photos'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  )
  with check (
    bucket_id = 'service-photos'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

drop policy if exists "Usuarios excluem seus arquivos" on storage.objects;
create policy "Usuarios excluem seus arquivos"
  on storage.objects for delete
  to authenticated
  using (
    bucket_id = 'service-photos'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

create or replace function public.set_updated_at()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists set_servicos_updated_at on public.servicos;
create trigger set_servicos_updated_at
  before update on public.servicos
  for each row execute function public.set_updated_at();

-- Permite que as alterações apareçam em tempo real em outros aparelhos.
do $$
begin
  alter publication supabase_realtime add table public.servicos;
exception
  when duplicate_object then null;
end $$;

do $$
begin
  alter publication supabase_realtime add table public.service_photos;
exception
  when duplicate_object then null;
end $$;
