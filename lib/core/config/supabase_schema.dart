/// SmartRoute Uganda — Supabase database schema.
///
/// This file documents the complete database schema for the SmartRoute Uganda
/// Supabase project. Use this to create/recreate the database in Supabase.
///
/// ## Setup instructions
///
/// 1. Create a Supabase project at https://supabase.com
/// 2. Open the SQL Editor in your Supabase dashboard
/// 3. Run each migration block below in order
/// 4. Enable Row Level Security (RLS) on all tables — SQL is included
/// 5. Update your .env / --dart-define values with your project URL and anon key
///
/// ## Tables
///
/// - profiles          User profile records (extends auth.users)
/// - vehicles          User-owned vehicles
/// - saved_places      User-saved locations
/// - road_reports      Community road hazard reports
/// - report_confirmations  Confirmation votes on reports
/// - journeys          Journey history records
/// - notifications     In-app notification records
/// - fleet_vehicles    Business fleet vehicle records
/// - gamification_events  Points and achievement events
///
/// ─── Migration 001 — Core tables ─────────────────────────────────────────────
///
/// ```sql
/// -- Enable necessary extensions
/// create extension if not exists "uuid-ossp";
///
/// -- ─── Profiles ───────────────────────────────────────────────────────────
/// create table public.profiles (
///   id          uuid references auth.users on delete cascade primary key,
///   name        text not null,
///   email       text not null,
///   phone       text,
///   account_type text not null default 'individual'
///                check (account_type in ('individual', 'business')),
///   business_name text,
///   avatar_url  text,
///   points      integer not null default 0,
///   level       text not null default 'explorer'
///                check (level in ('explorer', 'contributor', 'roadGuardian', 'mobilityChampion')),
///   badge_ids   text[] not null default '{}',
///   created_at  timestamptz not null default now(),
///   updated_at  timestamptz not null default now()
/// );
/// alter table public.profiles enable row level security;
/// create policy "Users can view their own profile"
///   on public.profiles for select using (auth.uid() = id);
/// create policy "Users can update their own profile"
///   on public.profiles for update using (auth.uid() = id);
///
/// -- Auto-create profile on signup
/// create or replace function public.handle_new_user()
/// returns trigger language plpgsql security definer set search_path = public as $$
/// begin
///   insert into public.profiles (id, name, email, account_type)
///   values (
///     new.id,
///     coalesce(new.raw_user_meta_data->>'name', split_part(new.email, '@', 1)),
///     new.email,
///     coalesce(new.raw_user_meta_data->>'account_type', 'individual')
///   );
///   return new;
/// end;
/// $$;
/// create trigger on_auth_user_created
///   after insert on auth.users
///   for each row execute procedure public.handle_new_user();
///
/// -- ─── Vehicles ───────────────────────────────────────────────────────────
/// create table public.vehicles (
///   id                    uuid default uuid_generate_v4() primary key,
///   user_id               uuid references public.profiles(id) on delete cascade not null,
///   name                  text not null,
///   category              text not null
///                          check (category in ('car','taxi','motorcycle','deliveryVehicle','van','truck','other')),
///   fuel_type             text not null
///                          check (fuel_type in ('petrol','diesel','electric','hybrid')),
///   consumption_per_100km decimal(5,2) not null default 8.0,
///   registration_id       text,
///   is_preferred          boolean not null default false,
///   created_at            timestamptz not null default now()
/// );
/// alter table public.vehicles enable row level security;
/// create policy "Users manage their own vehicles"
///   on public.vehicles for all using (auth.uid() = user_id);
///
/// -- ─── Saved Places ───────────────────────────────────────────────────────
/// create table public.saved_places (
///   id           uuid default uuid_generate_v4() primary key,
///   user_id      uuid references public.profiles(id) on delete cascade not null,
///   name         text not null,
///   address      text not null,
///   latitude     decimal(9,6) not null,
///   longitude    decimal(9,6) not null,
///   type         text not null default 'place',
///   is_home      boolean not null default false,
///   is_work      boolean not null default false,
///   is_favourite boolean not null default false,
///   last_used    timestamptz,
///   created_at   timestamptz not null default now()
/// );
/// alter table public.saved_places enable row level security;
/// create policy "Users manage their own saved places"
///   on public.saved_places for all using (auth.uid() = user_id);
///
/// -- ─── Road Reports ───────────────────────────────────────────────────────
/// create table public.road_reports (
///   id              uuid default uuid_generate_v4() primary key,
///   reporter_id     uuid references public.profiles(id) on delete set null,
///   is_anonymous    boolean not null default false,
///   category        text not null
///                    check (category in ('pothole','flooding','accident','roadworks',
///                                        'closure','heavyCongestion','dangerousCondition','otherHazard')),
///   description     text not null,
///   latitude        decimal(9,6) not null,
///   longitude       decimal(9,6) not null,
///   location_name   text not null,
///   photo_url       text,
///   status          text not null default 'unverified'
///                    check (status in ('unverified','communityConfirmed','underReview',
///                                      'verified','resolved','expired')),
///   confirmations   integer not null default 0,
///   expires_at      timestamptz default (now() + interval '7 days'),
///   created_at      timestamptz not null default now(),
///   updated_at      timestamptz not null default now()
/// );
/// alter table public.road_reports enable row level security;
/// create policy "Anyone can read active road reports"
///   on public.road_reports for select using (status != 'expired' and status != 'resolved');
/// create policy "Authenticated users can create reports"
///   on public.road_reports for insert with check (auth.role() = 'authenticated');
/// create policy "Reporters can update their own reports"
///   on public.road_reports for update using (auth.uid() = reporter_id);
/// create index idx_road_reports_location on public.road_reports (latitude, longitude);
/// create index idx_road_reports_status on public.road_reports (status);
///
/// -- ─── Report Confirmations ───────────────────────────────────────────────
/// create table public.report_confirmations (
///   id          uuid default uuid_generate_v4() primary key,
///   report_id   uuid references public.road_reports(id) on delete cascade not null,
///   user_id     uuid references public.profiles(id) on delete cascade not null,
///   confirmed_at timestamptz not null default now(),
///   unique(report_id, user_id)
/// );
/// alter table public.report_confirmations enable row level security;
/// create policy "Authenticated users can confirm reports"
///   on public.report_confirmations for insert with check (auth.role() = 'authenticated');
///
/// -- Auto-update confirmation count
/// create or replace function public.update_report_confirmations()
/// returns trigger language plpgsql security definer as $$
/// begin
///   update public.road_reports
///   set confirmations = (
///         select count(*) from public.report_confirmations where report_id = new.report_id
///       ),
///       status = case
///         when (select count(*) from public.report_confirmations where report_id = new.report_id) >= 10
///           then 'communityConfirmed'
///         else status
///       end,
///       updated_at = now()
///   where id = new.report_id;
///   return new;
/// end;
/// $$;
/// create trigger on_report_confirmed
///   after insert on public.report_confirmations
///   for each row execute procedure public.update_report_confirmations();
///
/// -- ─── Journeys ───────────────────────────────────────────────────────────
/// create table public.journeys (
///   id                uuid default uuid_generate_v4() primary key,
///   user_id           uuid references public.profiles(id) on delete cascade not null,
///   origin_name       text not null,
///   origin_address    text not null,
///   origin_lat        decimal(9,6) not null,
///   origin_lng        decimal(9,6) not null,
///   dest_name         text not null,
///   dest_address      text not null,
///   dest_lat          decimal(9,6) not null,
///   dest_lng          decimal(9,6) not null,
///   selected_route    text not null,
///   distance_km       decimal(8,2) not null default 0,
///   duration_minutes  integer not null default 0,
///   fuel_cost_ugx     decimal(10,2) not null default 0,
///   status            text not null default 'completed'
///                      check (status in ('active','completed','cancelled')),
///   started_at        timestamptz not null default now(),
///   completed_at      timestamptz
/// );
/// alter table public.journeys enable row level security;
/// create policy "Users manage their own journeys"
///   on public.journeys for all using (auth.uid() = user_id);
/// create index idx_journeys_user on public.journeys (user_id, started_at desc);
///
/// -- ─── Notifications ──────────────────────────────────────────────────────
/// create table public.notifications (
///   id            uuid default uuid_generate_v4() primary key,
///   user_id       uuid references public.profiles(id) on delete cascade not null,
///   title         text not null,
///   body          text not null,
///   category      text not null
///                  check (category in ('roadCondition','reportConfirmation',
///                                      'routeInfo','accountUpdate','announcement')),
///   action_route  text,
///   is_read       boolean not null default false,
///   created_at    timestamptz not null default now()
/// );
/// alter table public.notifications enable row level security;
/// create policy "Users manage their own notifications"
///   on public.notifications for all using (auth.uid() = user_id);
/// create index idx_notifications_user on public.notifications (user_id, created_at desc);
///
/// -- ─── Fleet Vehicles ─────────────────────────────────────────────────────
/// create table public.fleet_vehicles (
///   id                 uuid default uuid_generate_v4() primary key,
///   owner_id           uuid references public.profiles(id) on delete cascade not null,
///   name               text not null,
///   registration_id    text not null,
///   category           text not null,
///   driver_name        text not null,
///   status             text not null default 'idle'
///                       check (status in ('idle','enRoute','offline')),
///   total_distance_km  decimal(10,2) not null default 0,
///   is_active          boolean not null default true,
///   last_journey_date  timestamptz,
///   created_at         timestamptz not null default now()
/// );
/// alter table public.fleet_vehicles enable row level security;
/// create policy "Business owners manage their fleet"
///   on public.fleet_vehicles for all using (auth.uid() = owner_id);
///
/// -- ─── Gamification Events ─────────────────────────────────────────────────
/// create table public.gamification_events (
///   id          uuid default uuid_generate_v4() primary key,
///   user_id     uuid references public.profiles(id) on delete cascade not null,
///   event_type  text not null,
///   points      integer not null default 0,
///   reference   text,
///   created_at  timestamptz not null default now()
/// );
/// alter table public.gamification_events enable row level security;
/// create policy "Users view their own gamification events"
///   on public.gamification_events for select using (auth.uid() = user_id);
/// create policy "System inserts gamification events"
///   on public.gamification_events for insert with check (auth.role() = 'authenticated');
/// ```
///
/// ─── Setup complete ───────────────────────────────────────────────────────────
///
/// After running the SQL:
/// 1. Copy your Supabase project URL and anon key from Project Settings > API
/// 2. Add to your build command:
///    --dart-define=SUPABASE_URL=https://xxxx.supabase.co
///    --dart-define=SUPABASE_ANON_KEY=eyJ...
/// 3. Enable Email authentication in Supabase Auth > Providers
/// 4. (Optional) Enable Google OAuth
/// 5. Set up email templates in Auth > Email Templates
///
/// The app will automatically switch from demo mode to real Supabase data
/// once SUPABASE_URL and SUPABASE_ANON_KEY are provided.
class SupabaseSchema {
  SupabaseSchema._();
}
