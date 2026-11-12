# Diario della pagina nascosta (Supabase)

1. Crea un progetto gratuito su https://supabase.com (qualsiasi nome e regione).
2. Vai in **SQL Editor** ed esegui lo script qui sotto.
3. In **Project Settings → API** copia **Project URL** e la chiave **anon / public** in `docs/_data/guestbook.yml`.

```sql
create table public.guestbook (
  id bigint generated always as identity primary key,
  name text not null check (char_length(name) between 1 and 40),
  message text not null check (char_length(message) between 1 and 500),
  created_at timestamptz not null default now()
);

alter table public.guestbook enable row level security;

-- Tutti possono leggere e scrivere. Nessuno può modificare o cancellare dal sito.
create policy "leggi" on public.guestbook for select to anon using (true);
create policy "scrivi" on public.guestbook for insert to anon with check (true);

grant select, insert on public.guestbook to anon;
```

Per cancellare un messaggio sconveniente: **Table Editor → guestbook** nella dashboard di Supabase.
