-- =====================================================================
-- Impulso · base de datos en Supabase
-- Pegar todo este archivo en Supabase > SQL Editor > New query > Run.
-- Se puede correr más de una vez sin romper nada.
-- =====================================================================

-- 1) Entrenadores: quién puede ver a todo el equipo y cargar videos de ejercicios
create table if not exists public.coaches (
  user_id uuid primary key references auth.users on delete cascade
);
alter table public.coaches enable row level security;
drop policy if exists "cada uno ve si es entrenador" on public.coaches;
create policy "cada uno ve si es entrenador" on public.coaches
  for select to authenticated using (user_id = auth.uid());

create or replace function public.is_coach()
returns boolean language sql stable security definer set search_path = public
as $$ select exists (select 1 from public.coaches where user_id = auth.uid()) $$;
grant execute on function public.is_coach() to authenticated;

-- 2) Datos de cada persona (perfil, sesiones, desafíos, comidas, medidas, etc.)
--    col = tipo de dato ("sesiones", "desafios", "perfil"...), id = id del registro
create table if not exists public.docs (
  user_id    uuid not null default auth.uid() references auth.users on delete cascade,
  col        text not null,
  id         text not null,
  data       jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  primary key (user_id, col, id)
);
create index if not exists docs_col_idx on public.docs (col, user_id);
alter table public.docs enable row level security;

drop policy if exists "leer lo propio o ser entrenador" on public.docs;
create policy "leer lo propio o ser entrenador" on public.docs
  for select to authenticated using (user_id = auth.uid() or public.is_coach());
drop policy if exists "crear lo propio" on public.docs;
create policy "crear lo propio" on public.docs
  for insert to authenticated with check (user_id = auth.uid());
drop policy if exists "editar lo propio" on public.docs;
create policy "editar lo propio" on public.docs
  for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
drop policy if exists "borrar lo propio" on public.docs;
create policy "borrar lo propio" on public.docs
  for delete to authenticated using (user_id = auth.uid());

-- 3) Ejercicios: descripción, link y video que carga el entrenador; los ven todos
create table if not exists public.ejercicios (
  id         text primary key,
  data       jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);
alter table public.ejercicios enable row level security;
drop policy if exists "todos leen ejercicios" on public.ejercicios;
create policy "todos leen ejercicios" on public.ejercicios
  for select to authenticated using (true);
drop policy if exists "entrenador escribe ejercicios" on public.ejercicios;
create policy "entrenador escribe ejercicios" on public.ejercicios
  for all to authenticated using (public.is_coach()) with check (public.is_coach());

-- 4) Archivos: fotos y videos de ejercicios (público para ver, solo el entrenador sube)
insert into storage.buckets (id, name, public, file_size_limit)
values ('media', 'media', true, 52428800)
on conflict (id) do nothing;
drop policy if exists "entrenador sube media" on storage.objects;
create policy "entrenador sube media" on storage.objects
  for insert to authenticated with check (bucket_id = 'media' and public.is_coach());
drop policy if exists "entrenador cambia media" on storage.objects;
create policy "entrenador cambia media" on storage.objects
  for update to authenticated using (bucket_id = 'media' and public.is_coach());
drop policy if exists "entrenador borra media" on storage.objects;
create policy "entrenador borra media" on storage.objects
  for delete to authenticated using (bucket_id = 'media' and public.is_coach());

-- Permisos de acceso desde la app (los candados de arriba deciden qué fila ve cada uno)
grant usage on schema public to authenticated;
grant select on public.coaches to authenticated;
grant select, insert, update, delete on public.docs to authenticated;
grant select, insert, update, delete on public.ejercicios to authenticated;

-- 5) Tiempo real: que la vista Equipo se actualice sola
do $$ begin
  begin alter publication supabase_realtime add table public.docs; exception when duplicate_object then null; end;
  begin alter publication supabase_realtime add table public.ejercicios; exception when duplicate_object then null; end;
end $$;

-- =====================================================================
-- 6) DESPUÉS de crear tu cuenta en la app, correr SOLO esta línea
--    (cambiá el mail por el tuyo) para quedar como entrenador:
--
-- insert into public.coaches (user_id) select id from auth.users where email = 'TU_MAIL@ejemplo.com' on conflict do nothing;
-- =====================================================================
