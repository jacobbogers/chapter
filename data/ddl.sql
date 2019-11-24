create table users
(
  id uuid primary key,
  first_name text not null ,
  last_name text,
  email text not null,
  password_digest text,
  created_at timestamp default CURRENT_TIMESTAMP,
  updated_at timestamp default CURRENT_TIMESTAMP
);

create table social_providers
(
  id uuid primary key,
  name text,
  created_at timestamp default CURRENT_TIMESTAMP,
  updated_at timestamp default CURRENT_TIMESTAMP
);

create table social_provider_users
(
  id uuid primary key,
  provider_id uuid references social_providers(id) not null,
  provider_user_id text not null,
  user_id uuid references users(id) not null,
  created_at timestamp default CURRENT_TIMESTAMP,
  updated_at timestamp default CURRENT_TIMESTAMP
);

create table locations (
  id uuid primary key,
  country_code char(2) not null,
  city text not null,
  region text,
  postal_code text,
  created_at timestamp default CURRENT_TIMESTAMP,
  updated_at timestamp default CURRENT_TIMESTAMP
);

create table chapters
(
  id uuid primary key ,
  name text unique not null,
  description text not null,
  category text not null,
  details jsonb,
  location_id uuid references locations(id) not null,
  creator_id uuid references users(id) not null,
  created_at timestamp default CURRENT_TIMESTAMP,
  updated_at timestamp default CURRENT_TIMESTAMP
);

create table venues
(
  id uuid primary key,
  name text not null,
  location_id uuid references locations(id) not null,
  created_at timestamp default CURRENT_TIMESTAMP,
  updated_at timestamp default CURRENT_TIMESTAMP
);

create type sponsor_type as enum
('FOOD', 'VENUE', 'OTHER');

create table sponsors
(
  id uuid primary key,
  name text not null,
  website text,
  logo_path text,
  type sponsor_type not null,
  created_at timestamp default CURRENT_TIMESTAMP,
  updated_at timestamp default CURRENT_TIMESTAMP
);

create table tags
(
  id uuid primary key,
  name text not null
);

create table events
(
  id uuid primary key,
  name text not null,
  description text,
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  chapter_id uuid references chapters(id) not null ,
  venue_id uuid references venues(id),
  tag_id uuid references tags(id),
  canceled boolean default false,
  capacity int not null,
  created_at timestamp default CURRENT_TIMESTAMP,
  updated_at timestamp default CURRENT_TIMESTAMP
);

create table event_sponsors
(
  event_id uuid references events(id),
  sponsor_id uuid references sponsors(id),
  created_at timestamp default CURRENT_TIMESTAMP,
  updated_at timestamp default CURRENT_TIMESTAMP
);

create table user_chapters
(
  user_id uuid references users(id),
  chapter_id uuid references chapters(id),
  primary key(user_id, chapter_id),
  created_at timestamp default CURRENT_TIMESTAMP,
  updated_at timestamp default CURRENT_TIMESTAMP
);

create table rsvps
(
  user_id uuid references  users(id),
  event_id uuid references events(id),
  date timestamptz not null,
  on_waitlist boolean not null default FALSE,
  primary key(user_id, event_id),
  created_at timestamp default CURRENT_TIMESTAMP,
  updated_at timestamp default CURRENT_TIMESTAMP
);

create table user_bans
(
  user_id uuid references users(id),
  chapter_id uuid references chapters(id),
  primary key(user_id, chapter_id),
  created_at timestamp default CURRENT_TIMESTAMP,
  updated_at timestamp default CURRENT_TIMESTAMP
);

create table chapter_emails_endpoints
(
    chapter_id uuid references chapters(id),
    email_contact text not null,
    primary key(chapters_id, contact_email),
    contact_descr text not null, -- description for admin config panel 
    created_at timestamp default CURRENT_TIMESTAMP,
    updated_at timestamp default CURRENT_TIMESTAMP 
);

-- outgoing emails created per chapter
create table emails_sent
(
   id uuid,
   chapter_id uuid references chapters(id),
   email_sender text, -- address to display as sender 
   email_reply_to text, -- address to put in the reply too field
   primary_key(uuid),
   FOREIGN KEY (chapter_id, email_sender) REFERENCES chapter_emails_endpoints(chapter_id, email_contact),
   subject text not NULL,
  
   body_text text NOT NULL, -- plaintext
   body_html text, -- html variant of the body_text
   watchHTML text, -- html specific for apple watch
   amp text, -- message confirming to amp standard

)

